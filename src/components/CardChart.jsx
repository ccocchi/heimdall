import React from 'react';
import { ResponsiveLine } from '@nivo/line';

class CardChart extends React.Component {

  // Select labels from the x's of the first series
  guessXLabels = () => {
    return this.props.data[0].data.filter(({ x }) => x.endsWith('00')).map(d => d.x)
  }

  render() {
    return(
      <div className="card card__chart">
        {this.props.title && <div className="card-title">{this.props.title}</div>}

        <ResponsiveLine
            colors={this.props.colors}
            data={this.props.data}
            stacked={true}
            enableDots={false}
            enableArea={this.props.enableArea}
            animate={false}
            enableGridX={false}
            enableGridY={false}
            margin={{
              "top": 10,
              "bottom": 60,
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
              "tickValues": this.props.guessXLabels ? this.guessXLabels() : null
            }}
            legends={ this.props.showLegend ? [
              {
                "anchor": "bottom",
                "direction": "row",
                "translateY": 50,
                "itemWidth": 70,
                "itemHeight": 20,
                "symbolSize": 12,
                "symbolShape": "circle"
              }
            ] : []}
            minY="auto"
        />
      </div>
    )
  }
}

export default CardChart
