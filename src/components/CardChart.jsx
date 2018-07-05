import React from 'react';
import { ResponsiveLine } from '@nivo/line';

class CardChart extends React.Component {
  render() {
    return(
      <div className="card card__chart">
        <ResponsiveLine
            colors="pastel2"
            data={this.props.data}
            stacked={true}
            enableDots={false}
            enableArea={true}
            animate={false}
            enableGridX={false}
            enableGridY={false}
            margin={{
              "bottom": 40,
              "left": 40
            }}
            axisLeft={{
              "orient": "left",
              "tickSize": 5,
              "tickPadding": 5,
              "tickRotation": 0,
              "tickCount": 3
            }}
            axisBottom={{
              "orient": "bottom",
              "tickSize": 5,
              "tickCount": 3,
              "tickValues": ['14:00', '15:00', '16:00']
            }}
            minY="auto"
        />
      </div>
    )
  }
}

export default CardChart
