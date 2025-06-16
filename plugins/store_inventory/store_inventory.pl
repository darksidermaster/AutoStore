# --------------------------------------------------
# Autor          : Nageseio
# Data           : 16/06/2025
# Descrição      : Guardar itens no armazem com macro.
# Versão         : 1.0
# --------------------------------------------------

package store_inventory;

use strict;
use Plugins;
use Settings;
use Globals;
use Commands;
use Log qw(message warning error);
use Time::HiRes qw(sleep);

use lib 'plugins/macro/macro';
use Macro::Utilities qw(getInventoryIDs);

Plugins::register('store_inventory', 'Guarda os itens do inventário no armazém.', \&on_unload);

my @queue;
my $processing = 0;
my $hook;
my %no_store_items;
my $pluginPath = File::Spec->catfile($Plugins::current_plugin_folder, 'noStore.txt');


sub load_no_store_list {
    %no_store_items = ();

    my $file = $pluginPath;

    open(my $fh, '<', $file) or warning "Não foi possível abrir noStore.txt: $!\n", "warning";
    if (-e $file) {
        open(my $fh, '<', $file) or warning "Não foi possível abrir noStore.txt: $!\n", "warning";
        while (my $line = <$fh>) {
            chomp $line;
            next if $line eq '';
            $no_store_items{lc($line)} = 1;
        }
        close($fh);
        message "[StoreInventory] Lista de itens a não guardar carregada.\n", "info";
    } else {
        warning "[StoreInventory] Arquivo noStore.txt não encontrado.\n", "warning";
    }
}

$hook = Plugins::addHook('AI_pre', sub {
    return unless $processing;
    return unless @queue;

    my $item = shift @queue;
    if ($item) {
    	 if ($no_store_items{lc($item)}) {
        } else {
            Commands::run("storage add $item 0");
        }
        sleep 0.3;
    }

    # Se a fila de itens acabou
    unless (@queue) {
        Commands::run("storage close");
        $processing = 0;
    }
});

sub on_unload { }

# Comando manual que inicia o processo
my $commands = Commands::register(['store_inventory', 'Guarda o inventário no armazém', \&store_inventory_command]);

sub store_inventory_command {
    return if $processing;  # Impede execução dupla
    load_no_store_list();
    @queue = ();

    my %unique_items;
    foreach my $item (@{$char->inventory->getItems}) {
        next unless $item;
        next if $item->{equipped};
        $unique_items{lc($item->{name})} = 1;
    }

    foreach my $item_name (keys %unique_items) {
        push @queue, $item_name;
    }

    if (!@queue) {
        return;
    }

    $processing = 1;
    message "[StoreInventory] Iniciando armazenamento...\n", "info";
}

1;