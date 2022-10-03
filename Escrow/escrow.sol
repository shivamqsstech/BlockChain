// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// pragma experimental ABIEncoderV2;
import "ERC20.sol";
import "ERC721.sol";
contract escrow{

    // price nft id
    mapping(uint=>uint) priceOfnft;
    address _erc20tokenAddr;
    address _nfttokenAddr;

    constructor(address erc20Addr , address nfttokenAddr){
        _erc20tokenAddr = erc20Addr;
        _nfttokenAddr= nfttokenAddr;

    }

    using Counters for Counters.Counter;
    Counters.Counter private _dealid;

    struct deal {
        uint nftid;
        address buyer;
        address seller;
        uint amountlocked;
        uint nftIdlocked;
        bool confirmed;
        // dealid =_dealid;

    }

    

    mapping(uint=>deal) public dealdata;


    event nftRegistration(
        uint nftId,
        uint256 nftprice
    );

    event nftLocking(
        address _seller,
        uint256 _nftid,
        uint256 _dealid

    );

    event dealConfirmation(
        bool _Confirmation,
        uint256 _tokenTranfered,
        uint256 _nftTokenId

    );


    // Function to register nft and giving them a price

    function register(uint _nftokenid, uint _priceOfnft)  public{
        priceOfnft[_nftokenid]=_priceOfnft;

        emit nftRegistration(_nftokenid , _priceOfnft );

    }

    modifier IsOwner(uint _nftid,address nfttokenAddr){
        Mynft nftIns= Mynft(nfttokenAddr);
        require(msg.sender == nftIns.ownerOf(_nftid), "Only the Owner Can register nft");
        _;
    }

    modifier isBuyer(uint256 dealid){
        require(msg.sender == dealdata[dealid].buyer, "Only the buyer can Confirm deal");
        _;
    }

    modifier IsSeller(uint256 dealid){
        require(msg.sender == dealdata[dealid].seller, "Only The Seller Can Register Tokens");
        _;
    }



// deal id
    function lockNFT(uint256 _nftid,uint256 dealId)public IsOwner(_nftid ,_nfttokenAddr){

        Mynft nft= Mynft(_nfttokenAddr);
        dealdata[dealId].nftIdlocked =_nftid;
        nft.transferFrom(msg.sender, address(this),dealdata[dealId].nftIdlocked );

        emit nftLocking(msg.sender, _nftid, dealId);

    }

    function lockTokens(uint _tokenAmount,uint256 _nftid) public IsSeller(_nftid){
        uint256 dealid;
        myToken token1= myToken(_erc20tokenAddr);
        Mynft nftInstance = Mynft(_nfttokenAddr);

        require(_tokenAmount<=token1.balanceOf(msg.sender),"You do not Have Enough Token ");

        token1.transfer(msg.sender,_tokenAmount);


 // Deal Generation Part
        _dealid.increment();
        uint256 newdealId = _dealid.current();
        dealid = newdealId;

    deal memory dealdata1= deal({

        nftid: _nftid,
        buyer: msg.sender,
        seller: nftInstance.ownerOf(_nftid),
        amountlocked: _tokenAmount,
        nftIdlocked: 0,
        confirmed: false
         } );
        dealdata[dealid] = dealdata1;

    }

    function ConfirmDeal(uint256 _dealToBeConfirmed) public isBuyer(_dealToBeConfirmed){

        require(dealdata[_dealToBeConfirmed].nftid == dealdata[_dealToBeConfirmed].nftIdlocked, "Id locked is Not Same as nft id proposed");

        Mynft nft1= Mynft(_nfttokenAddr);
        myToken token1= myToken(_erc20tokenAddr);
        dealdata[_dealToBeConfirmed].confirmed =true;

        // transfering tokens
        token1.transferFrom(address(this),dealdata[_dealToBeConfirmed].seller,dealdata[_dealToBeConfirmed].amountlocked ); 

        // transfering nft
        nft1.transferFrom(address(this), dealdata[_dealToBeConfirmed].buyer,dealdata[_dealToBeConfirmed].nftIdlocked); 

        emit dealConfirmation(dealdata[_dealToBeConfirmed].confirmed, dealdata[_dealToBeConfirmed].amountlocked , _dealToBeConfirmed );
    }

     function canceldeal(uint _dealIdToBeCanceled) public{
        require(msg.sender == dealdata[_dealIdToBeCanceled].buyer, "Only the buyer can Confirm deal");
        Mynft nft1= Mynft(_nfttokenAddr);
        myToken token1= myToken(_erc20tokenAddr);

        token1.transfer(msg.sender, dealdata[_dealIdToBeCanceled].amountlocked);
        nft1.transferFrom(
            address(this),
            dealdata[_dealIdToBeCanceled].seller,
            dealdata[_dealIdToBeCanceled].nftIdlocked
        );
        
        delete dealdata[_dealIdToBeCanceled];
    }




    function viewDeal(uint256 id) external view returns(deal memory){
        return dealdata[id];
    }


    
}
