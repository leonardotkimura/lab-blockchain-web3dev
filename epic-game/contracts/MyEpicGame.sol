// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

// Contrato NFT para herdar.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Funcoes de ajuda que o OpenZeppelin providencia.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/Base64.sol";

contract MyEpicGame is ERC721  {
  // Nos vamos segurar os atributos dos nossos personagens em uma
  //struct. Sinta-se livre para adicionar o que quiser como um
  //atributo! (ex: defesa, chance de critico, etc).
  struct CharacterAttributes {
    uint characterIndex;
    string name;
    string imageURI;
    uint stamina;
    uint maxStamina;
    uint physicalAbility;
    uint technique;
    uint mentalStrength;
    uint specialAbility;
  }

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  // Uma pequena array vai nos ajudar a segurar os dados padrao dos
  // nossos personagens. Isso vai ajudar muito quando mintarmos nossos
  // personagens novos e precisarmos saber o HP, dano de ataque e etc.
  CharacterAttributes[] defaultCharacters;

  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

  mapping(address => uint256) public nftHolders;

  event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(uint newBossHp, uint newPlayerHp);


    struct BigBoss {
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
        }

        BigBoss public bigBoss;


  // Dados passados no contrato quando ele for criado inicialmente,
  // inicializando os personagens.
  // Vamos passar esse valores do run.js
  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterStamina,
    uint[] memory characterPhysicalAbility,
    uint[] memory characterTechnique,
    uint[] memory characterMentalStrength,
    uint[] memory characterSpecialAbility,

      string memory bossName, // Essas novas variáveis serão passadas via run.js ou deploy.js
  string memory bossImageURI,
  uint bossHp,
  uint bossAttackDamage
  )
  ERC721("Players", "PLAYER")
  {

     bigBoss = BigBoss({
    name: bossName,
    imageURI: bossImageURI,
    hp: bossHp,
    maxHp: bossHp,
    attackDamage: bossAttackDamage
  });
  console.log("Boss inicializado com sucesso %s com HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);

    // Faz um loop por todos os personagens e salva os valores deles no
    // contrato para que possamos usa-los depois para mintar as NFTs
    for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        stamina: characterStamina[i],
        maxStamina: characterStamina[i],
        physicalAbility: characterPhysicalAbility[i],
        technique: characterTechnique[i],
        mentalStrength: characterMentalStrength[i],
        specialAbility: characterSpecialAbility[i]
      }));

      CharacterAttributes memory c = defaultCharacters[i];
      console.log("Personagem inicializado: %s com %s de HP, e %s de ataque", c.name, c.stamina, c.physicalAbility);
    }
     _tokenIds.increment();
  }

    // Usuarios vao poder usar essa funcao e pegar a NFT baseado no personagem que mandarem!
  function mintCharacterNFT(uint _characterIndex) external {
    // Pega o tokenId atual (começa em 1 já que incrementamos no constructor).
    uint256 newItemId = _tokenIds.current();

    // A funcao magica! Atribui o tokenID para o endereço da carteira de quem chamou o contrato.

    _safeMint(msg.sender, newItemId);

    // Nos mapeamos o tokenId => os atributos dos personagens. Mais disso abaixo

    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      stamina: defaultCharacters[_characterIndex].stamina,
      maxStamina: defaultCharacters[_characterIndex].maxStamina,
      physicalAbility: defaultCharacters[_characterIndex].physicalAbility,
      technique: defaultCharacters[_characterIndex].technique,
      mentalStrength: defaultCharacters[_characterIndex].mentalStrength,
      specialAbility: defaultCharacters[_characterIndex].specialAbility
    });

    console.log("Mintou NFT c/ tokenId %s e characterIndex %s", newItemId, _characterIndex);

    // Mantem um jeito facil de ver quem possui a NFT
    nftHolders[msg.sender] = newItemId;

    // Incrementa o tokenId para a proxima pessoa que usar.
    _tokenIds.increment();
     emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);

  }

function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

    string memory strStamina = Strings.toString(charAttributes.stamina);
    string memory strMaxStamina = Strings.toString(charAttributes.maxStamina);
    string memory strPhysicalAbility = Strings.toString(charAttributes.physicalAbility);
    string memory strTechnique = Strings.toString(charAttributes.technique);
    string memory strMentalStrength = Strings.toString(charAttributes.mentalStrength);
    string memory strSpecialAbility = Strings.toString(charAttributes.specialAbility);

    string memory json = Base64.encode(
        abi.encodePacked(
        '{"name": "',
        charAttributes.name,
        ' -- NFT #: ',
        Strings.toString(_tokenId),
        '", "description": "Esta NFT da acesso ao meu jogo NFT!", "image": "',
        charAttributes.imageURI,
        '", "attributes": [ { "trait_type": "Stamina", "value": ',strStamina,', "max_value":',strMaxStamina,'}, { "trait_type": "Physical Ability", "value": ',
        strPhysicalAbility,'}, { "trait_type": "Technique", "value": ',
        strTechnique,'}, { "trait_type": "Mental Strength", "value": ',
        strMentalStrength,'}, { "trait_type": "Special Ability", "value": ',
        strSpecialAbility,'} ]}'
        )
    );

    string memory output = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    return output;
    }




function attackBoss() public {
  // Pega o estado do NFT do jogador
  uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
  CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
  console.log("\nJogador com personagem %s ira atacar. Tem %s de Stamina e %s de Poder de Ataque", player.name, player.stamina, player.physicalAbility);
  console.log("Boss %s tem %s de HP e %s de PA", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

    // Tenha certeza que o hp do jogador é maior que 0.
  require (
    player.stamina > 0,
    "Error: personagem precisa ter HP para atacar o boss."
  );

  // Tenha certeza que o HP do boss seja maior que 0.
  require (
    bigBoss.hp > 0,
    "Error: boss precisa ter HP para atacar o personagem."
  );

  // Permite que o jogador ataque o boss.
  if (bigBoss.hp < player.physicalAbility) {
    bigBoss.hp = 0;
  } else {
    bigBoss.hp = bigBoss.hp - player.physicalAbility;
  }

   if (player.stamina < bigBoss.attackDamage) {
    player.stamina = 0;
  } else {
    player.stamina = player.stamina - bigBoss.attackDamage;
  }

  console.log("Jogador atacou o boss. Boss ficou com HP: %s", bigBoss.hp);
  console.log("Boss atacou o jogador. Jogador ficou com stamina: %s\n", player.stamina);

  emit AttackComplete(bigBoss.hp, player.stamina);
}

function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
 // Pega o tokenId do personagem NFT do usuario
 uint256 userNftTokenId = nftHolders[msg.sender];
 // Se o usuario tiver um tokenId no map, retorne seu personagem
 if (userNftTokenId > 0) {
    return nftHolderAttributes[userNftTokenId];
  }
 // Senão, retorne um personagem vazio
 else {
    CharacterAttributes memory emptyStruct;
    return emptyStruct;
   }
}

function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
  return defaultCharacters;
}

function getBigBoss() public view returns (BigBoss memory) {
  return bigBoss;
}



}