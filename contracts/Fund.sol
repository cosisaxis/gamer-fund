// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public projectOwner;
    uint public fundingGoal;
    uint public totalFundsRaised;

    mapping(address => uint) public contributions;
    mapping(address => bool) public backers;

    bool public campaignEnded;

    event FundingReceived(address indexed backer, uint amount);
    event RefundClaimed(address indexed backer, uint amount);

    constructor(uint _fundingGoal) {
        projectOwner = msg.sender;
        fundingGoal = _fundingGoal * 1 ether;
    }

    modifier onlyOwner() {
        require(
            msg.sender == projectOwner,
            "Only the project owner can call this function"
        );
        _;
    }

    function contribute() external payable {
        require(msg.sender != address(0), "Invalid address");
        require(!campaignEnded, "The campaign has ended");

        uint amount = msg.value;
        contributions[msg.sender] += amount;
        totalFundsRaised += amount;

        emit FundingReceived(msg.sender, amount);

        if (totalFundsRaised >= fundingGoal) {
            campaignEnded = true;
        }
    }

    function registerBacker() external {
        require(!backers[msg.sender], "Backer already registered");

        backers[msg.sender] = true;
    }

    function claimRefund() external {
        require(
            campaignEnded && totalFundsRaised < fundingGoal,
            "Campaign not ended or funding goal reached"
        );
        require(contributions[msg.sender] > 0, "No contributions found");

        uint refundAmount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        totalFundsRaised -= refundAmount;

        emit RefundClaimed(msg.sender, refundAmount);

        payable(msg.sender).transfer(refundAmount);
    }

    function withdrawFunds() external onlyOwner {
        require(campaignEnded, "Campaign is still ongoing");
        require(totalFundsRaised >= fundingGoal, "Funding goal not reached");

        uint amount = address(this).balance;
        require(amount > 0, "No funds available for withdrawal");

        campaignEnded = false; // Prevent reentrancy

        payable(projectOwner).transfer(amount);
    }

    function getRemainingTime() public view returns (uint) {
        if (!campaignEnded) {
            return 0;
        }
        return 0;
    }
}
