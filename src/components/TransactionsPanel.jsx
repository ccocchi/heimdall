import React from 'react';
import queryString from 'query-string';
import moment from 'moment';

import InputLabel from '@material-ui/core/InputLabel';
import MenuItem from '@material-ui/core/MenuItem';
import FormControl from '@material-ui/core/FormControl';
import Select from '@material-ui/core/Select';

import CardNumber from './CardNumber';
import CardChart from './CardChart';

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
      currentDetails: null,
      unit: 'ms',
      data: [],
      chartData: null,
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

    const sortFunction  = (a, b) => a.value === b.value ? 0 : (a.value > b.value ? -1 : 1)

    let data;
    if (sortBy === 'consuming') {
      const total = unsorted_data.reduce((total, n) => total + n.value, 0)
      const percent_data = unsorted_data.map(obj => {
        const roundedValue = Math.round((obj.value / total) * 10000) / 100
        return {...obj, value: roundedValue };
      })

      data = percent_data.sort(sortFunction).slice(0, 15);
    } else {
      data = unsorted_data.sort(sortFunction).slice(0, 15);
    }

    const max  = data.reduce((res, { value }) => value > res ? value : res, 0);

    const currentDetails = data[0].endpoint;

    const chartResponse  = await fetch(`http://0.0.0.0:4567/transactions/details?${queryString.stringify({endpoint: currentDetails})}`);
    const chartData      = await chartResponse.json();

    const timesData = chartData.times.map(({id, data}) => {
      return { id: id, data: data.map(({x, y}) => {
        return { x: moment(x).format('HH:mm'), y: y }
      }) }
    })

    console.log(timesData);

    this.setState({ data: data, max: max, currentDetails: currentDetails, chartData: timesData })
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
    const { data, max, unit, chartData }  = this.state;

    return (
      <div className="panel panel__transactions">
        <div className="panel-left">
          <h3>Transactions</h3>

          { isEmpty(sortValues) ? null : this.renderSelect(sortValues) }

          <div className="transactions">
            {data.map(c => <TransactionLine {...c} unit={unit} max={max} key={c.endpoint} />)}
          </div>
        </div>
        <div className="panel-right">
          <CardNumber title="Avg response time" value="118ms" />
          <CardNumber title="95th percentile" value="216ms" />

          {chartData && <CardChart data={chartData} />}
        </div>
      </div>
    )
  }
}

export default TransactionsPanel;
