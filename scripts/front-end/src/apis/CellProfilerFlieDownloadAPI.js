import axios from 'axios';

export const cellLevelSummary = axios.create({
    baseURL: process.env.REACT_APP_API_SERVER + '/v1/cellprofiler/cellular/',
});

export const wellLevelSummary = axios.create({
    baseURL: process.env.REACT_APP_API_SERVER + '/v1/cellprofiler/wellular/',
});

export const fileList = axios.create({
    baseURL: process.env.REACT_APP_API_SERVER + '/v1/cellprofiler/filelist/',
});

export const logs = axios.create({
    baseURL: process.env.REACT_APP_API_SERVER + '/v1/cellprofiler/logs/',
});