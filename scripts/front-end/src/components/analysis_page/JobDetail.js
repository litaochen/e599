import React from 'react';

import fileDownload from 'js-file-download';
import { cellLevelSummary, wellLevelSummary, fileList, logs }
    from '../../apis/CellProfilerFlieDownloadAPI';
import pipeline from '../../apis/PipelineAPI';


// import stylesheet
import '../../css/style.css';

class JobDetail extends React.Component {
    constructor(props) {
        super(props);

        // setup data details
        this.state = {
            job_detail: this.props.data,
        };

        // bind method
        this.show_job_detail = this.show_job_detail.bind(this);
        this.show_job_input = this.show_job_input.bind(this);
        this.show_job_output = this.show_job_output.bind(this);
        this.onDownloadFileClicked = this.onDownloadFileClicked.bind(this);
        this.onDownloadPipelineClicked = this.onDownloadPipelineClicked.bind(this);
    };

    // update page when new user-name passed in
    componentWillReceiveProps(nextProps) {
        if (nextProps.data !== this.state.data) {
            this.setState({
                job_detail: nextProps.data
            })
        }
    }


    // handle pipeline file download
    async onDownloadPipelineClicked(filename) {
        const response = await pipeline.get('download/', {
            params: {
                pipeline_id: this.state.job_detail.pipeline_id
            }
        });

        // add ".cppipe" extension if not there
        const the_file_name = filename.slice(-6) === 'cppipe' ? filename : filename + '.cppipe'
        fileDownload(response.data, the_file_name)
    }

    // handle run file download
    async onDownloadFileClicked(file_type) {
        let the_api = null;
        let the_file_name = 'data.zip';
        switch (file_type) {
            case 'cellular':
                the_api = cellLevelSummary;
                the_file_name = 'cell_level_summary.zip';
                break;
            case 'wellular':
                the_api = wellLevelSummary;
                the_file_name = 'well_level_summary.zip';
                break;
            case 'filelist':
                the_api = fileList;
                the_file_name = 'file_list.zip';
                break;
            case 'logs':
                the_api = logs;
                the_file_name = 'run_logs.zip';
                break;
            default:
                break;
        }

        const response = await the_api.get('', {
            responseType: 'arraybuffer',
            params: {
                run_id: this.state.job_detail._id
            }
        });

        fileDownload(response.data, the_file_name);
    }

    // function to generate job detail section
    show_job_detail() {
        return (
            <table className='ui very basic table'>
                <thead>
                    <tr><th className="two wide"></th>
                        <th className="thirteen wide"></th>
                    </tr>
                </thead>
                <tbody>
                    <tr key={this.state.job_detail.name === '' ? (Math.random()) : this.state.job_detail.name}>
                        <td><label>Job Name: </label></td>
                        <td> <label>{this.state.job_detail.name}</label> </td>
                    </tr>
                    <tr key={this.state.job_detail.submitted_by === '' ? (Math.random()) : this.state.job_detail.username}>
                        <td><label>Submitted by: </label></td>
                        <td> <label>{this.state.job_detail.username}</label> </td>
                    </tr>
                    <tr key={this.state.job_detail.start_date === '' ? (Math.random()) : this.state.job_detail.start_date}>
                        <td><label>Date: </label></td>
                        <td> <label>{this.state.job_detail.start_date}</label> </td>
                    </tr>
                    <tr key={this.state.job_detail.status === '' ? (Math.random()) : this.state.job_detail.status}>
                        <td><label>Status: </label></td>
                        <td> <label>{this.state.job_detail.status}</label> </td>
                    </tr>
                    <tr key={this.state.job_detail.description === '' ? (Math.random()) : this.state.job_detail.description}>
                        <td><label>Description: </label></td>
                        <td>
                            <div className="ui message">
                                <div>
                                    <label>{this.state.job_detail.description}</label>
                                </div>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        )
    }


    // get input file info
    show_job_input() {
        return (
            <div className="ui three column grid">
                <div className="column">
                    <div className="ui segment">
                        <i className="file alternate big icon"></i>
                        <label>
                            <a href="#" onClick={() => this.onDownloadFileClicked('filelist')}>
                                File List
                        </a>
                        </label>
                    </div>
                </div>
                <div className="column">
                    <div className="ui segment">
                        <i className="file code outline big icon"></i>
                        <label>
                            <a href="#" onClick={() => this.onDownloadPipelineClicked('the_pipeline.cppipe')}>
                                Pipeline Config</a>
                        </label>

                    </div>
                </div>
            </div>
        )
    };

    // get output file info
    show_job_output() {
        return (
            <div className="ui three column grid">
                <div className="column">
                    <div className="ui segment">
                        <i className="file alternate big icon"></i>
                        <label><a href="#" onClick={() => this.onDownloadFileClicked('cellular')}>
                            Cell-level summary</a>
                        </label>
                    </div>
                </div>
                <div className="column">
                    <div className="ui segment">
                        <i className="file alternate big icon"></i>
                        <label><a href="#" onClick={() => this.onDownloadFileClicked('wellular')}>
                            Well-level summary</a>
                        </label>
                    </div>
                </div>
                <div className="column">
                    <div className="ui segment">
                        <i className="file alternate big icon"></i>
                        <label><a href="#" onClick={() => this.onDownloadFileClicked('logs')}>
                            Run Logs</a>
                        </label>
                    </div>
                </div>
            </div>
        )
    };

    // render the page with data
    render() {
        return (
            <div className="ui container">
                <div className="ui container segment">
                    <h2>Job detail</h2>
                    {this.show_job_detail()}
                </div>
                <div className="ui container segment">
                    <h2>Job Input</h2>
                    {this.show_job_input()}
                </div>
                <div className="ui container segment">
                    <h2>Result</h2>
                    {this.show_job_output()}
                </div>
            </div >
        )
    }


};

export default JobDetail;