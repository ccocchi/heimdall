import queryString from 'query-string';

const HOST = 'http://0.0.0.0:4567'

export const fetchFromAPI = async (path, params, mappingFn) => {
  const endpoint  = `${HOST}${path}?${queryString.stringify(params)}`;

  try {
    const response  = await fetch(endpoint);
    const json      = await response.json()

    return mappingFn !== undefined ? mappingFn(json) : json
  }
  catch(e) {
    return null;
  }
}
