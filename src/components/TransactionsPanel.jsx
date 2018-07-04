import React from 'react';
import InputLabel from '@material-ui/core/InputLabel';
import MenuItem from '@material-ui/core/MenuItem';
import FormControl from '@material-ui/core/FormControl';
import Select from '@material-ui/core/Select';

function isEmpty(value) {
  return  value === undefined ||
          value === null ||
          (typeof value === "object" && Object.keys(value).length === 0) ||
          (typeof value === "string" && value.trim().length === 0)
}

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

class TransactionsPanel extends React.Component {

  constructor(props) {
    super(props);
    this.state = { sortValue: Object.keys(props.sortValues)[0] };
  }

  handleSelectChange = event => {
    this.setState({ sortValue: event.target.value });
  }

  renderSelect(values) {
    return(
      <FormControl>
        <InputLabel htmlFor="order-by">Sort by</InputLabel>
        <Select
          value={this.state.sortValue}
          onChange={this.handleSelectChange}
          inputProps={{
            name: 'orderBy',
            id: 'order-by',
          }}
        >
          {Object.entries(values).map(([value, str]) => <MenuItem key={value} value={value}>{str}</MenuItem>)}
        </Select>
      </FormControl>
    )
  }

  render() {
    const { data, max, sortValues } = this.props;

    return (
      <div className="panel panel__transactions">
        <h3>Transactions</h3>

        { isEmpty(sortValues) ? null : this.renderSelect(sortValues) }

        <div className="transactions">
          {data.map(c => <TransactionLine {...c} max={max} key={c.avg_time} />)}
        </div>
      </div>
    )
  }
}

export default TransactionsPanel;
