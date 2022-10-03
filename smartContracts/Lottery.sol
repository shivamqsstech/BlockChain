pragma solidity ^0.5.11;


contract Lottery{
    
    address payable[] players;
    address payable owner;
    uint public totalAmount;
    mapping(address => uint) registered;

    constructor() public {
        totalAmount = 0;
        owner = msg.sender;
    }

    function register() public payable {
        if(registered[msg.sender] == 1) {
            revert("Already registered for lottery!");
        }

        if(msg.value < 1000) {
            revert("Minimum deposit is 1000");
        }

        players.push(msg.sender);
        registered[msg.sender] = 1;
        totalAmount = totalAmount + msg.value;
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
    }

    function draw() public{
        require(msg.sender == owner, "You must be the owner");

        uint index=random()%players.length;
        players[index].transfer(totalAmount);
    }
}