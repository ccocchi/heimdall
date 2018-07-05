import React from 'react';

class CardNumber extends React.PureComponent {
  render() {
    return (
      <div className="card card__number">
        <div className="card-title">{this.props.title}</div>
        <div className="card-value">{this.props.value}</div>
      </div>
    )
  }
}

export default CardNumber;
