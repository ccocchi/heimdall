import moment from 'moment';

export const isEmpty = (value) => {
  return  value === undefined ||
          value === null ||
          (typeof value === "object" && Object.keys(value).length === 0) ||
          (typeof value === "string" && value.trim().length === 0)
}

export const valueSortFn = (a, b) => a.value === b.value ? 0 : (a.value > b.value ? -1 : 1)

export const convertTimeValuesFn = ({ id, data }) => {
  const convertedData = data.map(obj => Object.assign(obj, { x: moment(obj.x).format('HH:mm') }));
  return { id: id, data: convertedData };
}
