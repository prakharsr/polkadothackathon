// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.8.0;

contract minBidApprovalContract {
    address payable public beneficiary;
    mapping (address => uint) amountPayable;
    uint public votingStartTime;
    uint public votingEndTime;
    uint public approvalEndTime;
    bool isApproved;
    uint public maxBid;
    address public maxBidder;
    uint public minApproval;

    constructor(uint _startTime, uint _endTime, uint _approvalEndTime, uint _minApproval, address payable _beneficiary) {
        beneficiary = _beneficiary;
        votingStartTime = _startTime;
        votingEndTime = _endTime;
        approvalEndTime = _approvalEndTime;
        minApproval = _minApproval;
        isApproved = false;
    }

    modifier duringVoting(uint time) {
        
        require(time >= votingStartTime && time <= votingEndTime && time <= approvalEndTime);
        _;
    }

    modifier approvalWait(uint time) {
        
        require(time > votingEndTime && time <=approvalEndTime);
        _;
    }

    function bid() public payable duringVoting(block.timestamp){
        require(msg.value > 0 && msg.value > minApproval && msg.value > maxBid);
        if(maxBidder == address(0)) {
            amountPayable[msg.sender] = msg.value;
            maxBidder = msg.sender;
            maxBid = msg.value;
        }
        else {
            amountPayable[maxBidder] += maxBid;
            maxBidder = msg.sender;
            maxBid = msg.value;
        }
    }

    function withdraw() public returns (bool) {
        uint amount = amountPayable[msg.sender];
        
        if(amount > 0) {
            amountPayable[msg.sender] = 0;
            if(!msg.sender.send(amount)) {
                amountPayable[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function approval() public approvalWait(block.timestamp) returns (bool){

        if(maxBid > minApproval && !isApproved) {
            isApproved = true;
            if(beneficiary.send(maxBid)) {
                return true;
            }
        }
        return false;
    }

}