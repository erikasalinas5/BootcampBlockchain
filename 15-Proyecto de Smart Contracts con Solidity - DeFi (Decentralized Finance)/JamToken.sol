// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract JamToken {

    // Declaraciones 
    string public name = "JAM Token";
    string public symbol = "JAM";
    // Cantidad de tokens que se van a crear
    uint256 public totalSupply = 1000000000000000000000000; // 1 millon de tokens
    // Establece el número de decimales, tengo 24 ceros en totalSupply
    // mas los decimales, da el millon de tokens que quiero crear
    uint8 public decimals = 18;

    // Evento para la transferencia de tokens de un usuario
    event Transfer (
        // Indexed es para que quede indexada y poder filtrarla cuando se escanee
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    // Evento para la aprobacion de un operador
    event Approval (
        address indexed _owner, 
        address indexed _spender, 
        uint256 _value
    );

    // Estructuras de datos 
    // mapping para obtener el balance de una persona
    mapping(address => uint256) public balanceOf;
    // selecciona el allowance, que es la cantidad que permitimos que un
    // SPENDER gestione del OWNER
    mapping(address => mapping(address => uint)) public allowance;

    // Constructor 
    // Cuando lo despliegue, el balance o el millon del smart contract se iran
    // a la cuenta que los despliega o owner
    constructor(){
        balanceOf[msg.sender] = totalSupply;
    }

    // Transferencia de tokens de un usuario
    function transfer(address _to, uint256 _value) public returns (bool success){
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Aprobacion de una cantidad para ser gastada por un operador
    // para enviar un token debo escribir 1000.000.000.000.000.000 debido a 
    // los 18 numeros decimales que le dimos al smart contract
    function approve(address _spender, uint256 _value) public returns (bool success){
        // sender para dar permisos al spender
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Transferencia de tokens especificando el emisor
    // Owner (20 tokens) -> Operador (5 Tokens) = 15 Tokens 
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

}
