// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.4.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.4.2/access/Ownable.sol";

contract ArtToken is ERC721, Ownable {
    // ============================================
    // Initial Statements
    // ============================================

    // Smart Contract Constructor
    constructor (string memory _name, string memory _symbol)
    ERC721(_name, _symbol){}

    // NFT token counter
    uint256 COUNTER;

    // Pricing of NFT Tokens (price of the artwork)
    uint256 public fee = 5 ether;

    // Data structure with the properties of the artwork
    struct Art {
        string name;
        uint256 id;
        uint256 dna;
        uint8 level;
        uint8 rarity;
    }

    // Storage structure for keeping artworks
    Art [] public art_works;

    // Declaration of an event 
    event NewArtWork (address indexed owner, uint256 id, uint256 dna);
    
    // ============================================
    // Help functions
    // ============================================

    // Creation of a random number (required for NFT token properties)
    function _createRandomNum(uint256 _mod) internal view returns (uint256){
        // Creo un hash, le añado un timestamp para que sea unico
        bytes32 has_randomNum = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        // el randomNumber es una conversión de hash a número
        uint256 randonNum = uint256(has_randomNum);
        // El modulo es para que pase solo una cierta cantidad de números
        return randonNum % _mod;
    }

    // NFT Token Creation (Artwork)
    // Una parte de la función se encargará de la lógica y otra del pago del usuario
    function _createArtWork(string memory _name) internal {
        // Siempre asignar terminos divisibles por 10 
        // o en potencias en base 10 y se convierte en uint8
        uint8 randRarity = uint8(_createRandomNum(1000));
        // Nivel de rareza para el adn
        uint256 randDna = _createRandomNum(10**16);
        // Se crea la obra de arte. El 1 es de un level donde el usuario puede pagar por aumentarla
        Art memory newArtWork = Art(_name, COUNTER, randDna, 1, randRarity);
        // Se añade a la lista
        art_works.push(newArtWork);
        // Se le asigna la obra de arte a quien la está creando
        _safeMint(msg.sender, COUNTER);
        // Se emite el evento
        emit NewArtWork(msg.sender, COUNTER, randDna);
        // Se cambia el counter para que siempre sea distinta
        COUNTER++;
    }

    // NFT Token Price Update 
    // onlyOwner para que sea modificada solo por nosotros
    // El onlyowner hace parte de las funciones o modificadores de la libreria ownable
    function updateFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    // Visualize the balance of the Smart Contract (ethers)
    function infoSmartContract() public view returns(address, uint256){
        // La dirección del smart contract se toma con this y extrayendo la direccion
        address SC_address = address(this);
        // se hace la conversión de weis a ethers
        uint256 SC_money = address(this).balance / 10**18;
        return (SC_address, SC_money);
    }

    // Obtaining all created NFT tokens (artwork)
    function getArtWorks() public view returns (Art [] memory){
        return art_works;
    }

    // Obtaining a user's NFT tokens
    // usar memory para este tipo de estructuras o para string
    function getOwnerArtWork(address _owner) public view returns (Art [] memory){
        // el balance nos dirá cuantas obras de arte tiene
        Art [] memory result = new Art[](balanceOf(_owner));
        // el counter va a recorrer esas obras de arte
        uint256 counter_owner = 0;
        // Se recorren todas las obras de arte y si el owner consigue con el
        // que estoy consultando la añade
        for (uint256 i = 0; i < art_works.length; i++){
            if (ownerOf(i) == _owner){
                result[counter_owner] = art_works[i];
                counter_owner++;
            }
        }
        return result;
    }

    // ============================================
    // NFT Token Development
    // ============================================

    // NFT Token Payment
    // La funcion será pública, por eso no lleva _
    function createRandomArtWork(string memory _name) public payable {
        // Valida que el valor que pago sea mayor o igual
        // a la tasa necesaria a pagar
        require(msg.value >= fee);
        _createArtWork(_name);
    }

    // Extraction of ethers from the Smart Contract to the Owner
    // Esta funcion sera ejecutada solo por el owner
    function withdraw() external payable onlyOwner{
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }

    // Level up NFT Tokens
    function levelUp(uint256 _artId) public {
        // Validacion para que solo lo pueda hacer el owner
        require(ownerOf(_artId) == msg.sender);
        Art storage art = art_works[_artId];
        art.level++;
    }


}
