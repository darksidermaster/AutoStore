# Sistema de Armazenamento Automatizado para OpenKore

Este sistema permite que o personagem armazene automaticamente os itens no armazém ao atingir determinado peso, utilizando macros personalizadas com suporte a plugin.

## 📦 Requisitos

- OpenKore com suporte a `eventMacro`.
- Plugin `store_inventory` (fornecido separadamente).
- Arquivo `config.txt` com `autoStorage` **desativado**.
- Plugin incluído na lista de carregamento no `config/sys.txt`.

---

## ⚙️ Configurações Iniciais

### 1. Desativar autoStorage

No arquivo `config.txt`, defina:

```txt
autoStorage 0
```

---

### 2. Adicionar o Plugin para Carregamento automático

No arquivo `config/sys.txt`, adicione `store_inventory` à lista `loadPlugins_list`:

```txt
loadPlugins_list store_inventory
```

---

### 3. Itens que **não** devem ser armazenados

Crie (ou edite) o arquivo:

```
plugins/store_inventory/noStore.txt
```

Liste os nomes dos itens (um por linha) que devem ser mantidos no inventário:

```txt
Morango
Escama Afiada
```

---

## 🔁 Macro de Armazenamento

Crie ou edite o arquivo `macros.txt` e adicione as seguintes macros:

```perl
automacro PesoAlto {
    weight > 80%        # Peso máximo antes de iniciar o armazenamento (ajustável)
    timeout 300         # Tempo mínimo entre ativações (em segundos)
    run-once 1
    call ArmazemAutomatizado
}

macro ArmazemAutomatizado {
    do move payon                    # Mapa alvo (ajustar conforme necessário)
    pause 1

    do move payon 181 104           # Coordenadas do NPC de armazém (ajustar conforme o mapa)
    pause 1

    do talknpc 181 104 c r1 n       # Comando de interação com o NPC (ajustar conforme NPC)
    pause 2

    pausemacro 1 !storageopened     # Aguarda armazém abrir
    pause 2

    do store_inventory              # Armazena os itens, exceto os listados em noStore.txt
    pause 1

    do storage close                # Fecha o armazém
    pause 1

    release PesoAlto                # Libera a automacro para nova ativação
}
```

---

## 🧠 Observações Importantes

- O valor `weight > 80%` pode ser ajustado de acordo com a capacidade do seu personagem.
- Os comandos `do move` e `do talknpc` devem ser adaptados ao local e NPC de armazém do seu mapa.
- Certifique-se de que o personagem tenha acesso livre até o NPC (sem obstáculos ou teleportes necessários).
- O plugin `store_inventory` deve estar corretamente instalado na pasta `plugins/`.

---

## 🧪 Exemplo de Fluxo

1. Personagem atinge 81% de peso.
2. Macro leva até o NPC de armazém em Payon.
3. Interage e armazena os itens (exceto os definidos no `noStore.txt`).
4. Fecha o armazém e volta ao modo de espera.

---

## 🛠 Suporte e Customização

Caso use mapas diferentes de `payon`, modifique:

- `do move <mapa>`
- `do move <mapa> <x> <y>`
- `do talknpc <x> <y> <comandos>`

Consulte o comando `where` dentro do jogo para obter as coordenadas exatas do NPC.
