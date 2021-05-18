import React, {Component} from 'react';
import Web3 from 'web3';
import './App.css';
import Repute from './abis/Repute.json';

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

    const networkId = await web3.eth.net.getId()
    const networkData = Repute.networks[networkId]
    if(networkData) {
      const abi = Repute.abi
      const address = networkData.address
      var contract = new web3.eth.Contract(abi, address)
      this.setState({ contract })

      // Load user count and users
      const userCount = await contract.methods.userCount().call()
      this.setState({ userCount })
      // Load colors
      for(let i=0; i<userCount; i++) {
        const user = await contract.methods.users(i).call()
        this.setState({
          users: [...this.state.users, user]
        })
      }
    } else {
      window.alert('Smart contract is not deployed to detected network.')
    }
  }

  constructor(props) {
    super(props)
    this.state = {
      account: '',
      contract: null,
      userCount: 0,
      users: []
    }
  }

  render() {
    return (
      <div className="App">
        Welcome to my React + Truffle applicatoin
        <div>
          <p>
            User account address <b>{this.state.account}</b>
          </p>
          <form onSubmit={ (event) => {
            event.preventDefault()
            this.state.contract.methods.register().send({from: this.state.account})
              .once('receipt', (receipt) => {
                console.log('receipt')
                window.alert('succesfully registered')
              })
              .on('error', (error) => {
                window.alert('Error occurred')
              })
          }}>
            <input
              type='submit'
              className='btn btn-block btn-primary'
              value='Register'
            />
          </form>
        </div>
        <p>
          User count: <b>{this.state.userCount}</b>
        </p>
        {this.state.users.map((user, key) => {
          return (
            <div key={key} className="col-md-3 mb-3">
              User: {user}
              <input type='submit' value='Invite'/>
            </div>
          )
        })}
      </div>
    );
  }
}

export default App;
