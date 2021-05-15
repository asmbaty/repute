import React, {Component} from 'react';
import Web3 from 'web3';
import './App.css';

class App extends Component {
  
  async componentWillMount() {
    await this.loadWeb3()
    await this.loadBlockchainData()
  }

  async loadWeb3() {
    if(window.ethereum) {
      window.web3 = new Web3(window.ethereum)
      await window.ethereum.enable() // browser
    }
    else if(window.web3) {
      window.web3 = new Web3(window.web3.currentProvider) // metamask
    }
    else {
      window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!')
    }
  }

  async loadBlockchainData() {
    const web3 = window.web3
    const accounts = await web3.eth.getAccounts()
    this.setState({ account: accounts[0] })
  }

  constructor(props) {
    super(props)
    this.state = {
      account: ''
    }
  }

  render() {
    return (
      <div className="App">
        Welcome to my React + Truffle applicatoin
        <p>
          User account address <b>{this.state.account}</b>
        </p>
      </div>
    );
  }
}

export default App;
