import React from 'react'

const data = [
  {
    endpoint: "/v1/influence/search",
    avg_time: 5399
  },
  {
    endpoint: "V1::ProfilesController#search",
    avg_time: 5240
  },
  {
    endpoint: "/catalog/search",
    avg_time: 4325
  },
  {
    endpoint: "/v1/forms/website_contact",
    avg_time: 3869
  },
  {
    endpoint: "/v1/profiles/:id/snas_stats",
    avg_time: 3518
  },
  {
    endpoint: "/v1/influence/search",
    avg_time: 3200
  },
  {
    endpoint: "V1::ProfilesController#search",
    avg_time: 2930
  },
  {
    endpoint: "/catalog/search",
    avg_time: 2409
  },
  {
    endpoint: "/v1/forms/website_contact",
    avg_time: 1208
  },
  {
    endpoint: "/v1/profiles/:id/snas_stats",
    avg_time: 1198
  }
]
const max = 5399

class TransactionLine extends React.Component {
  occupationPercent = () => {
    return (this.props.avg_time / this.props.max) * 100;
  }

  render() {
    return (
      <div className="transaction-line">
        <div className="ratio-line" style={{ width: `${this.occupationPercent()}%`}}></div>
        <div className="content">
          {this.props.endpoint}
          <div className="value">{this.props.avg_time}ms</div>
        </div>
      </div>
    );
  }
}

class Dashboard extends React.Component {
  render() {
    return (
      <div className="main-container">
        <div className="menu">
          <h3>Monitoring</h3>
          <ul>
            <li><a href="#">Overview</a></li>
            <li className="current"><a href="#">Transactions</a></li>
            <li><a href="#">Databases</a></li>
          </ul>
        </div>
        <div className="content">
          <h3>Transactions</h3>

          <select id="orderBy">
            <option selected>Slowest query time</option>
            <option>Most time consuming</option>
          </select>

          <div className="transactions">
            {data.map(c => <TransactionLine {...c} max={max} key={c.avg_time} />)}
          </div>

        </div>
      </div>
      // <div className="App">
      //   <header className="App-header">
      //     <h1 className="App-title">Performance Dashboard</h1>
      //   </header>
      //
      //   <div className="main-container">
      //     <div className="time-ranges">
      //       <div className="selected">3h</div>
      //       <div>6h</div>
      //       <div>12h</div>
      //       <div>1d</div>
      //     </div>
      //
      //     <div className="transactions">
      //       <div className="header">
      //         <h3>Transactions</h3>
      //         <div className="column-name">Avg resp. time</div>
      //       </div>
      //
      //       {data.map(c => <TransactionLine {...c} max={max} key={c.avg_time} />)}
      //     </div>
      //   </div>
      // </div>
    );
  }
}

export default Dashboard
