// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

contract MultisigWallet {

    address public owner;
    address[] public members;

    modifier onlyMember(){
        bool isMember = false;
        for(uint i = 0; i < members.length; i++){
            if(members[i] == msg.sender){
                isMember = true;
                break;
            }
        }
        require(isMember == true, "Only Member can call this function");
        _;
    }

    mapping(address => uint) balanceOf;

    event MemberAdded(address addedByMember, address memberAdded, uint time);
    event MemberRemoved(address removedBy, address ownerRemoved, uint time);
    event Deposited(address sender, uint amount, uint time);
    event Withdrawal(address sender, uint amount, uint time);

    constructor(){
        owner = msg.sender;
        members.push(owner);
    }

    function setNewMember(address _newMember) external onlyMember {
        for(uint i = 0; i < members.length; i++){
            if(members[i] == _newMember){
                revert("Address already exit");
            }
        }
        members.push(_newMember);    
    }

    function removeMember(address _member) external onlyMember {
        bool findMember;
        uint indexedMember;
        for(uint i = 0; i < members.length; i++){
            if(members[i] == _member){
                findMember = true;
                indexedMember = i;
                break;
            }
        }

        require(findMember == true, "Not a member here");

        members[indexedMember] = members[members.length - 1];
        members.pop();
    }

    function deposit() payable external onlyMember {
        require(balanceOf[msg.sender] >= 0, "insufficient funds");
        balanceOf[msg.sender] = msg.value;

        emit Deposited(msg.sender, msg.value, block.timestamp); 
    }

    function Withdraw(uint _amount) external onlyMember {
        require(balanceOf[msg.sender] >= _amount);
        balanceOf[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);

        emit Withdrawal(msg.sender, _amount, block.timestamp);
    }

    function balance() external view returns(uint){
        return (address(this)).balance;
    }
}