// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
contract Bank{
    uint public loanRoi;
    uint public withdrawfee;
    address owner;

    uint loanDeadline = 1 days;

    struct LoandData{
        uint loanAmount;
        uint loanTakingtime;
        uint loanPaymenttime;
        bool previousloantaken;
        

    

    }

    mapping( address => bool) register;
    mapping(address =>uint)  userBalance;
    mapping (address =>LoandData)  loanData;
    //mapping(address => LoandData) loanInfo;


    event AccountCreated(
        address user
    );

    event Withdraw(
        address user,
        uint amount
    );

    event Deposit(
        address user,
        uint amount
    );

    event AccountClosed(
        address user
    );

    event loanDetail(
        address user,
        uint amount
    );

    event LoanRepaid(
        address user,
        uint amount
    );

     constructor(){
        owner = msg.sender;
        withdrawfee = 100000000000000000;
        loanRoi = 1200;
    }



    modifier isNotRegistered(){
        require(
            !register[msg.sender],
            "User Already Present"
            );
            _;
    }
    modifier isRegistered(){
        require(
            register[msg.sender],
            "Create Bank Account First"
        );
        _;
        
    }

    modifier isUserEligibleforLoan{
        require(
            loanData[msg.sender].previousloantaken,
            "You Are Not Eligible for Loan Again"
        );
        _;
    }

    modifier isUserOwner{
        require((msg.sender)==owner,
         "Only The Owner Can Call this function"

        );
        _;
    }



    function createAccount() external isNotRegistered(){
        register[msg.sender] =true;
        userBalance[msg.sender] =0;

        emit AccountCreated(msg.sender);

    }

    function deposit() external payable isRegistered(){
        require(
            msg.value > 0,
            "Enter the valid Amount"
        );
        userBalance[msg.sender] +=msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function accountBalance() public view isRegistered returns(uint){
        return userBalance[msg.sender];

    }

    function withdraw(uint _withdrawAmount) external isRegistered(){
        require(
            (userBalance[msg.sender] >= _withdrawAmount),
            "Insufficient fund in your Account"
            );
            payable(msg.sender).transfer(_withdrawAmount);
            userBalance[msg.sender] -=_withdrawAmount;

            emit Withdraw(msg.sender, _withdrawAmount);

    }

    function ApplyforLoan(uint _loanamount)  isRegistered isUserEligibleforLoan public{

        require(userBalance[msg.sender]>= ((_loanamount*loanRoi*loanDeadline)/10000*60*60*24),
        "Not Enough Balance to take Loan");
        loanData[msg.sender].loanAmount += _loanamount;
        loanData[msg.sender].loanTakingtime= block.timestamp;
        loanData[msg.sender].previousloantaken= true;

        emit loanDetail(msg.sender, _loanamount);

    }

    function liquidateUserLoan(address __address) public isUserOwner returns(uint _balance) {
        require(loanData[__address].previousloantaken ==true,
        "User has not taken any previous Loan"
        );
        require(
            loanData[__address].loanTakingtime >=loanData[__address].loanTakingtime + 1 days,
            "User still have time to clear Loan Amount"
            );
            uint si= loanData[__address].loanAmount + ((loanData[__address].loanAmount*loanRoi*(loanData[__address].loanTakingtime + 1 days)))/(10000*365);
            require(
                userBalance[__address] >= si,
                "User does not have suffiecient Balance"
            );
            userBalance[__address]-=si;
            // LoanData[__address].loanAmount-=
            return userBalance[__address];


    }
        function clearLoanAmount() external payable isRegistered() {
        
        require(
            loanData[msg.sender].loanAmount > 0, 
            "No loan amount to clear"
        );
        
        require(
            !(msg.value ==0),
            "Enter valid Amount"
            );

        require(
            msg.value >= loanData[msg.sender].loanAmount,
            "Enter the valid amount"
            );



        loanData[msg.sender].loanPaymenttime=block.timestamp;
        uint  time=loanData[msg.sender].loanPaymenttime=block.timestamp - loanData[msg.sender].loanTakingtime;
        uint intrest = ((loanData[msg.sender].loanAmount*loanRoi *time)/10000*60*60*24);
           //uint totalLoan= loandata[msg.sender].loanAmount + (( loandata[msg.sender].loanAmount *loanRoi*time)/10000*365)
           
           
           //require ((msg.value)+ intrest > loanData[msg.sender].lo)
           loanData[msg.sender].loanAmount -= ( (msg.value) + intrest);

        emit LoanRepaid(msg.sender, msg.value);
    }


    function closeAccount() public isRegistered(){
        require(
            (loanData[msg.sender].loanAmount) ==0,
            "Loan not repaid"
        );
        payable(msg.sender).transfer(userBalance[msg.sender]);
        delete register[msg.sender];
        delete userBalance[msg.sender];
        emit AccountClosed(msg.sender);
    }

}