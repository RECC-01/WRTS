// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 WRTS — Wrapped RTS
 Native RTS Wrapper for RECCNETWORK Blockchain
(Genesis Asset Wrapper)

 - ERC20 compatible
 - 1:1 backing with native RTS
 - Required for AMM / Swap / Liquidity
 - Similar to WETH / WAVAX / WMATIC
 - Production ready

 Author: RECCNETWORK Blockchain Ecosystem
*/

contract WRTS {

    /* =====================================================
                        ERC20 METADATA
    ===================================================== */
    string public name = "Wrapped RTS";
    string public symbol = "WRTS";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    /* =====================================================
                        EVENTS
    ===================================================== */
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    /* =====================================================
                        RECEIVE RTS
    ===================================================== */
    receive() external payable {
        deposit();
    }

    /* =====================================================
                        DEPOSIT (RTS → WRTS)
    ===================================================== */
    function deposit() public payable {
        require(msg.value > 0, "WRTS: zero deposit");
        balanceOf[msg.sender] += msg.value;
        totalSupply += msg.value;

        emit Deposit(msg.sender, msg.value);
        emit Transfer(address(0), msg.sender, msg.value);
    }

    /* =====================================================
                        WITHDRAW (WRTS → RTS)
    ===================================================== */
    function withdraw(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "WRTS: insufficient balance");

        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;

        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    /* =====================================================
                        ERC20 LOGIC
    ===================================================== */
    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - value;
        }
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(balanceOf[from] >= value, "WRTS: insufficient balance");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }
}
