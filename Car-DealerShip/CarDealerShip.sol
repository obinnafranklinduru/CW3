// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

contract CarDealer {
    address payable public carSeller;
    address payable public carBuyer;
    uint public carPrice;

    error OnlyOwner();
    error OnlyBuyer();
    error CheckState();

    /*
        Personal info: I tried to enclosed my modifier if statement with curly braces{}
        just like normal javascript if statement style - if(){}
        But my code ran into error of Warning: Unreachable code.
        While removing the curly braces{}, the code worked.
        I think one has to be careful while working with curly braces{} in solidity.
    */

    modifier onlyOwner() {
        if(msg.sender != carSeller)
            revert OnlyOwner();
        _;
    }

    modifier onlyBuyer() {
        if(msg.sender != carBuyer)
            revert OnlyBuyer();
        _;
    }

    modifier checkstate(State _state) {
        if(state != _state)
            revert CheckState();
        _;
    }

    enum State { Created, Locked, Released, Closed }
    State public state;

    constructor() payable {
        carSeller = payable(msg.sender);
        carPrice = msg.value / 3;
    }

    function purchase() external checkstate(State.Created) payable {
        require(msg.value == carPrice, "Not enough Ethereum, Our car price is 1ETH");
        carBuyer = payable(msg.sender);
        state = State.Locked;
    }

    function comfirmation() external onlyBuyer checkstate(State.Locked){
        state = State.Released;
    }

    function refund() external onlyOwner checkstate(State.Released){
        state = State.Closed;
        carSeller.transfer(address(this).balance);
    }

    function suspend() external onlyOwner checkstate(State.Created){
        state = State.Closed;
        carSeller.transfer(address(this).balance);
    }
}