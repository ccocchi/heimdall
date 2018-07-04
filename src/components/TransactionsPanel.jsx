import React from 'react';
import queryString from 'query-string';

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
    return (this.props.value / this.props.max) * 100;
  }

  render() {
    return (
      <div className="transaction-line">
        <div className="ratio-line" style={{ width: `${this.occupationPercent()}%`}}></div>
        <div className="content">
          {this.props.endpoint}
          <div className="value">{this.props.value}{this.props.unit}</div>
        </div>
      </div>
    );
  }
}

class TransactionsPanel extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      sortValue: Object.keys(props.sortValues)[0],
      unit: 'ms',
      data: [],
      max: 0
    };
  }

  unitForSort = (sort) => {
    switch (sort) {
      case 'slowest':
        return 'ms';
      case 'consuming':
        return '%';
      case 'throughput':
        return 'rpm';
      default:
        return 'ms';
    }
  }

  handleSelectChange = event => {
    const value = event.target.value;

    this.setState({ sortValue: value, unit: this.unitForSort(value) });
    this.refreshData(value);
  }

  async refreshData(sortBy) {
    const params        = { sort_by: sortBy }
    const endpoint      = `http://0.0.0.0:4567/transactions?${queryString.stringify(params)}`

    const response      = await fetch(endpoint);
    const unsorted_data = await response.json();

    const sortFunction  = (a, b) => a.value > b.value ? -1 : 1

    let data;
    if (sortBy === 'consuming') {
      const total = unsorted_data.reduce((total, n) => total + n.value, 0)
      console.log('total', total);
      const percent_data = unsorted_data.map(obj => {
        const res = {...obj, value: ((obj.value / total) * 100).toFixed(2) }
        return res;
      })

      data = percent_data.sort(sortFunction).slice(0, 15);
    } else {
      data = unsorted_data.sort(sortFunction).slice(0, 15);
    }

    const max  = data.reduce((res, { value }) => value > res ? value : res, 0);

    this.setState({ data: data, max: max })
  }

  componentDidMount() {
    this.refreshData(this.state.sortValue);
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
    const { sortValues } = this.props;
    const { data, max, unit }  = this.state;

    return (
      <div className="panel panel__transactions">
        <h3>Transactions</h3>

        { isEmpty(sortValues) ? null : this.renderSelect(sortValues) }

        <div className="transactions">
          {data.map(c => <TransactionLine {...c} unit={unit} max={max} key={c.value} />)}
        </div>
      </div>
    )
  }
}

export default TransactionsPanel;
