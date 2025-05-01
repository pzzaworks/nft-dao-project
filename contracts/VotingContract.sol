// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IMainNFTContract {
    function getAddressBalance(address _address) external view returns (uint);
}

interface ISubNFTContract {
    function getAddressBalance(address _address) external view returns (uint);
}

contract VotingContract is Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    
    Counters.Counter public totalVoteCount;

    string public subject = "Subject?";
    string public desciption = "Desciption...";

    mapping(uint256 => address) nftAdresses;

    uint256 private optionsCount = 5;
    mapping(uint256 => string) options;

    mapping(uint256 => Counters.Counter) optionsVoteCount;

    mapping(uint256 => uint256) equalMostVotedOptionsId;
    Counters.Counter equalMostVotedOptionsIdCount;

    mapping(address => uint256) addressSelectedOptionId;
    mapping(address => Counters.Counter) addressVoteCount;

    string private result = "";
    uint256 private resultOptionId = 0;
    bool public resultState = false;

    uint256 public startDate = 0000000000;
    uint256 public endDate = 0000000000;

    bool public voteState = true;

    uint256 public price = 0.01 ether;

    address public founder1 = 0x0000000000000000000000000000000000000000;
    address public founder2 = 0x0000000000000000000000000000000000000000;
    address public communityAndPartners = 0x0000000000000000000000000000000000000000;
    address public treasury = 0x0000000000000000000000000000000000000000;

    constructor() {
        options[0] = "";
        options[1] = "Option 1";
        options[2] = "Option 2";
        options[3] = "Option 3";
        options[4] = "Option 4";
        options[5] = "Option 5";

        nftAdresses[0] = 0x0000000000000000000000000000000000000000;
        nftAdresses[1] = 0x0000000000000000000000000000000000000000;
        //nftAdresses[2] = 0x0000000000000000000000000000000000000000
    }

    function vote(uint256 optionId) public payable {
        require(voteState == true, "Voting haven't start yet.");
        require(addressVoteCount[msg.sender].current() < 1, "This wallet address already voted");

        uint256 addressBalanceNFTName1 = IMainNFTContract(nftAdresses[0]).getAddressBalance(msg.sender);
        uint256 addressBalanceNFTName2 = ISubNFTContract(nftAdresses[1]).getAddressBalance(msg.sender);

        require(addressBalanceNFTName1 > 0 || addressBalanceNFTName2 > 0, "This wallet address cannot join the voting");

        require(optionId > 0 && optionId < 5, "Option with this option id doesn't exist.");
        
        require(msg.value >= price, "Insufficient funds.");

        totalVoteCount.increment();
        optionsVoteCount[optionId].increment();
        addressVoteCount[msg.sender].increment();
        addressSelectedOptionId[msg.sender] = optionId;
    }

    function getAddressVote(address _address) public view returns (string memory)  {
        require(addressVoteCount[_address].current() > 0, "This wallet address didn't join the voting yet");
        
        string memory currentAddressSelectedOption = options[addressSelectedOptionId[_address]];
        return bytes(currentAddressSelectedOption).length > 0 ? string(abi.encodePacked(currentAddressSelectedOption)) : "";
    }

    function calculateResult() public onlyOwner {
        require(totalVoteCount.current() > 0, "Result cannot be calculated because there is zero vote now.");
        
        uint256 mostVotedOptionId = 0;

        for(uint256 i = 0; i < optionsCount; i++) {
            if(optionsVoteCount[i].current() >= optionsVoteCount[mostVotedOptionId].current()) {
                mostVotedOptionId = i;

                if(i != mostVotedOptionId && optionsVoteCount[i].current() == optionsVoteCount[mostVotedOptionId].current()) {
                    equalMostVotedOptionsId[i] = i;
                    equalMostVotedOptionsIdCount.increment();
                }
            }
        }

        if(equalMostVotedOptionsIdCount.current() > 0) {
            uint256 randomIndex = uint256(blockhash(block.number - 1)) % equalMostVotedOptionsIdCount.current();
            mostVotedOptionId = equalMostVotedOptionsId[randomIndex];
        }

        result = options[mostVotedOptionId];
        resultOptionId = mostVotedOptionId;
    }

    function updatePrice(uint256 newPrice) public onlyOwner {
        price = newPrice;
    }

    function updateVoteState(bool newVoteState) public onlyOwner {
        voteState = newVoteState;
    }

    function updateResultState(bool newResultState) public onlyOwner {
        resultState = newResultState;
    }

    function updateStartDate(uint256 newStartDate) public onlyOwner {
        startDate = newStartDate;
    }

    function updateEndDate(uint256 newEndDate) public onlyOwner {
        endDate = newEndDate;
    }

    function showResult() public view returns(string memory) {
        require(resultState == true, "The result hasn't announced yet.");
        return bytes(result).length > 0 ? string(abi.encodePacked(result)) : "";
    }

    function showResultOptionID() public view returns(uint256) {
        require(resultState == true, "The result hasn't announced yet.");
        return resultOptionId;
    }

    function showOptionsVoteCount(uint256 optionId) public view returns(uint256) {
        require(resultState == true, "The result hasn't announced yet.");
        return optionsVoteCount[optionId];
    }

    function withdraw() public payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Not enough balance.");

        (bool successFounder1, ) = payable(founder1).call{value: ((balance * 250) / 1000)}("");
        require(successFounder1, "Transfer failed.");

        (bool successFounder2, ) = payable(founder2).call{value: ((balance * 250) / 1000)}("");
        require(successFounder2, "Transfer failed.");

        (bool successCommunityAndPartners, ) = payable(communityAndPartners).call{value: ((balance * 250) / 1000)}("");
        require(successCommunityAndPartners, "Transfer failed.");

        (bool successTreasury, ) = payable(treasury).call{value: ((balance * 250) / 1000)}("");
        require(successTreasury, "Transfer failed.");

        (bool successOwner, ) = payable(msg.sender).call{value: (address(this).balance)}("");
        require(successOwner, "Transfer failed.");
    }
}