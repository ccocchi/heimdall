import React from 'react';
import classnames from 'classnames';

import InputLabel from '@material-ui/core/InputLabel';
import MenuItem from '@material-ui/core/MenuItem';
import FormControl from '@material-ui/core/FormControl';
import Select from '@material-ui/core/Select';

import CardNumber from './CardNumber';
import CardChart from './CardChart';

import { fetchFromAPI } from '../api';
import { isEmpty, valueSortFn, convertTimeValuesFn } from '../utils';

class TransactionLine extends React.Component {
  occupationPercent = () => {
    return (this.props.value / this.props.max) * 100;
  }

  render() {


    return (
      <div className={classnames("transaction-line", { current: this.props.current })} onClick={this.props.refreshFn(this.props.endpoint)}>
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
      currentEndpoint: null,
      unit: 'ms',
      data: [],
      detailsData: {
        breakdownData: null,
        throughputData: null,
        percentile: null,
        mean: null
      },
      max: 0,
      errorMsg: null
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

  refreshDetails = endpoint => async () => {
    const chartData       = await fetchFromAPI('/transactions/details', { endpoint: endpoint });
    const breakdownData   = chartData.times.map(series => convertTimeValuesFn(series))
    const throughputData  = chartData.throughput.map(series => convertTimeValuesFn(series))

    this.setState({
      currentEndpoint: endpoint,
      detailsData: {
        breakdownData: breakdownData,
        throughputData: throughputData,
        mean: chartData.mean,
        percentile: chartData.percentile
      }
    });
  }

  async refreshData(sortBy) {
    const raw_data  = await fetchFromAPI('/transactions', { sort_by: sortBy });

    if (isEmpty(raw_data)) {
      this.setState({ errorMsg: true });
      return;
    }

    const data      = raw_data.sort(valueSortFn).slice(0, 15)
    const maxValue  = data.reduce((res, { value }) => value > res ? value : res, 0);

    const currentEndpoint = data[0].endpoint;
    const chartData       = await fetchFromAPI('/transactions/details', { endpoint: currentEndpoint });

    const breakdownData   = chartData.times.map(series => convertTimeValuesFn(series))
    const throughputData  = chartData.throughput.map(series => convertTimeValuesFn(series))

    this.setState({
      data: data,
      max: maxValue,
      currentEndpoint: currentEndpoint,
      detailsData: {
        breakdownData: breakdownData,
        throughputData: throughputData,
        mean: chartData.mean,
        percentile: chartData.percentile
      },
      unit: this.unitForSort(sortBy),
      errorMsg: false
    })
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
    const { data, max, unit, detailsData:{breakdownData, throughputData, mean, percentile} }  = this.state;

    return (
      <div className="panel panel__transactions">
        <div className="panel-left">
          <h3>Transactions</h3>

          { isEmpty(sortValues) ? null : this.renderSelect(sortValues) }

          { this.state.errorMsg ? <div className="error-msg">No data for selected period.</div> : null }

          <div className="transactions">
            {data.map(c =>
              <TransactionLine
                  {...c}
                  unit={unit}
                  max={max}
                  key={c.endpoint}
                  refreshFn={this.refreshDetails}
                  current={c.endpoint === this.state.currentEndpoint}
              />)}
          </div>
        </div>
        <div className="panel-right">
          <div className="row row__numbers">
            <CardNumber title="Avg response time" value={`${mean || '-'} ms`} />
            <CardNumber title="95th percentile" value={`${percentile || '-'} ms`} />
          </div>

          {breakdownData &&
            <CardChart
                data={breakdownData}
                guessXLabels
                showLegend
                enableArea
                title="Transaction breakdown"
                colors="pastel2"
            />}

          {throughputData &&
            <CardChart
                data={throughputData}
                guessXLabels
                title="Throughput"
                colors="d320c"
            />}
        </div>
      </div>
    )
  }
}

export default TransactionsPanel;
