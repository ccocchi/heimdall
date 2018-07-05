import React from 'react';
import moment from 'moment';

import InputLabel from '@material-ui/core/InputLabel';
import MenuItem from '@material-ui/core/MenuItem';
import FormControl from '@material-ui/core/FormControl';
import Select from '@material-ui/core/Select';

import CardNumber from './CardNumber';
import CardChart from './CardChart';

import { fetchFromAPI } from '../api';
import { isEmpty, valueSortFn } from '../utils';

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

  unitForSort = sort => {
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

    this.setState({ sortValue: value });
    this.refreshData(value);
  }

  async refreshPanel(sortBy) {
  }

  async refreshList(sortBy) {
  }

  async refreshDetails(endpoint) {
  }

  async refreshData(sortBy) {
    const raw_data  = await fetchFromAPI('/transactions', { sort_by: sortBy });
    const data      = raw_data.sort(valueSortFn).slice(0, 15)
    const maxValue  = data.reduce((res, { value }) => value > res ? value : res, 0);

    const currentDetails  = data[0].endpoint;
    const chartData       = await fetchFromAPI('/transactions/details', { endpoint: currentDetails });
    const timesData       = chartData.times.map(({id, data}) => {
      return { id: id, data: data.map(({x, y}) => {
        return { x: moment(x).format('HH:mm'), y: y }
      }) }
    })

    this.setState({ data: data, max: maxValue, currentDetails: currentDetails, chartData: timesData, unit: this.unitForSort(sortBy) })
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
