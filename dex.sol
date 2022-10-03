// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "ERC20.sol";
// import safemath.sol";

contract dex{
    mapping(address=> bool) TokenAddress;

    modifier IsAlreadyRegistered(address TAddress){
      require(!TokenAddress[TAddress], "Token Already Registered");
      _;
    }
    
     function Register(address TAddress) IsAlreadyRegistered(TAddress) public{
       TokenAddress[TAddress]= true;
    }

    modifier IsTokenARegistered(address tokenAaddressA ,address TokenaddressB){
      require(!TokenAddress[tokenAaddressA],"token A Not Registered to swap");
      require(!TokenAddress[TokenaddressB],"token B Not Registered to swap");
      _;
    }

    event TradeCompleted(
      address tokenAaddressA,
      uint tokenAPrice,
      address TokenaddressB,
      uint tokenBPrice
    );

    // Token Trading Part

    function tradeTokens(address tokenAaddressA, address TokenaddressB, uint256 NumOftoken) IsTokenARegistered(tokenAaddressA, TokenaddressB) public{
      myToken tokenA = myToken(tokenAaddressA); //token A INSTANCE
      myToken TokenB= myToken(TokenaddressB);  //TOKEN B ISNTANCE
      require(tokenA.balanceOf(address(this))<=NumOftoken || tokenA.balanceOf(address(this))>0, "Doesnt Have enough token A to trade");
      require(TokenB.balanceOf(address(this))<=NumOftoken || tokenA.balanceOf(address(this))>0,"Doesnt Have enough token B to trade");


      // Token Echange rate part

      uint  tokenAPrice = tokenA.balanceOf(TokenaddressB) / TokenB.balanceOf(tokenAaddressA);
      uint  tokenBPrice = tokenA.balanceOf(tokenAaddressA) / TokenB.balanceOf(TokenaddressB);
      // uint totalPriceOfTokenA= NumOftoken * tokenAPrice;
      uint TokenToBeTransfered= tokenAPrice / tokenBPrice;

      // Token Exchange Part

      tokenA.transferFrom(msg.sender, address(this),NumOftoken);
      TokenB.transfer(address(this), TokenToBeTransfered);
  emit TradeCompleted(tokenAaddressA,tokenAPrice ,TokenaddressB,tokenBPrice);
    }

    function TokenAprice(address tokenAaddressA, address TokenaddressB) public view returns(uint){
      myToken tokenA = myToken(tokenAaddressA); //token A INSTANCE
      myToken TokenB= myToken(TokenaddressB);  //TOKEN B ISNTANCE

      uint  tokenAPrice = tokenA.balanceOf(address(this)) / TokenB.balanceOf(address(this));
      return tokenAPrice;

    }

      function TokenBprice(address tokenAaddressA, address TokenaddressB) public view returns(uint){
      myToken tokenA = myToken(tokenAaddressA); //token A INSTANCE
      myToken TokenB= myToken(TokenaddressB);  //TOKEN B ISNTANCE

      uint  tokenBPrice = (TokenB.balanceOf(address(this)) / tokenA.balanceOf(address(this)));
      return tokenBPrice;

    }

    

}
