a solidity ^0.4.18;

// ----------------------------------------------------------------------------

// ERC Token Standard #20 Interface

// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

// ----------------------------------------------------------------------------

contract DNetTESTToken {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);



}



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------

contract SafeMath {

    function safeAdd(uint a, uint b) public pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }



    function safeSub(uint a, uint b) public pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }



    function safeMul(uint a, uint b) public pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }



    function safeDiv(uint a, uint b) public pure returns (uint c) {

        require(b > 0);

        c = a / b;

    }



}



// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------

contract Owned {

    address public owner;

    address public newOwner;

    uint public supply;



    event OwnershipTransferred(address indexed _from, address indexed _to);



    function Owned() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;

    }



    function acceptOwnership() public {

        require(msg.sender == newOwner);

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);

    }    



}



// ----------------------------------------------------------------------------

// Pause contract

// ----------------------------------------------------------------------------

contract Pausable is Owned {

  event Pause();

  event Unpause();



  bool public paused = false;





  modifier whenNotPaused() {

    require(!paused);

    _;

  }





  modifier whenPaused() {

    require(paused);

    _;

  }





  function pause() onlyOwner whenNotPaused public {

    paused = true;

    emit Pause();

  }





  function unpause() onlyOwner whenPaused public {

    paused = false;

    emit Unpause();

  }

}



contract tokenDistributor is Owned, SafeMath, Pausable{

    address tokenHolderAddress;

    mapping(address => uint) whitelist;

    

    uint public amountRaised;   

    uint public deadline;     



    uint public rate;   

    DNetTESTToken public dnetToken;  



    mapping(address => uint256) public balanceOf;

    bool crowdsaleClosed = false;   

    

        

    function tokenDistributor(address tokenHolderAddr, uint durationInMinutes, uint tokensPerEther, address erc20Addr) public{

            deadline = now + durationInMinutes * 1 minutes;

            rate = tokensPerEther;

            dnetToken = DNetTESTToken(erc20Addr);   

            tokenHolderAddress = tokenHolderAddr;

    }

    

    modifier beforeDeadline() { if (now <= deadline) _; }

    modifier isAlive() { if (crowdsaleClosed == false) _;}

    

    function () public payable isAlive beforeDeadline whenNotPaused {

        uint tokens;

        tokens = safeMul(msg.value,rate);

        

        if(isBeforeExpiryDate(msg.sender)){

            require(dnetToken.transferFrom(tokenHolderAddress, msg.sender, tokens)); // transfer the tokens

            tokenHolderAddress.transfer(msg.value);

        }else{

            revert();

        }

    }



    function destroy() public onlyOwner{

        selfdestruct(tokenHolderAddress);

        crowdsaleClosed = true;

    }

    

    function isBeforeExpiryDate(address addr) internal returns (bool valid){

        valid = whitelist[addr] > now;

    }

    

    function addToWhiteList(address addr, uint s) public isAlive onlyOwner{

        whitelist[addr] = safeAdd(block.timestamp, s) ;

    }

    

}
