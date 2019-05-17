import React from 'react'
import { post } from 'axios';
import { Redirect } from 'react-router-dom';
import { Dropdown } from 'semantic-ui-react';

import pipeline from '../../apis/PipelineAPI';
import startRun from '../../apis/PipelineStartAPI';
import dataset from '../../apis/DataSetAPI';

class SubmitJob extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            user_name: this.props.user_name,
            pipelines: [],
            datasets: [],
            name: '',
            selected_dataset: '',
            selected_pipeline: null,
            description: '',
            is_input_valid: false
        }

        this.validate_inputs = this.validate_inputs.bind(this);
        this.onJobNameChanged = this.onJobNameChanged.bind(this);
        this.onDescriptionChanged = this.onDescriptionChanged.bind(this);
        this.loadPipelines = this.loadPipelines.bind(this);
        this.loadDataSetsList = this.loadDataSetsList.bind(this);


        this.onPipelineSelected = this.onPipelineSelected.bind(this);
        this.onDatasetSelected = this.onDatasetSelected.bind(this);
        this.onFormSubmit = this.onFormSubmit.bind(this);
        this.onjobSubmit = this.onjobSubmit.bind(this);
    }


    // function to load pipeline list from API server
    async loadPipelines(user_name) {
        const response = await pipeline.get('', {
            params: {
                username: user_name
            }
        })

        // extract the desired value
        // console.log(response.data)
        response.data.forEach(item => {
            item.key = item._id;
            item.value = item._id;
            item.text = item.filename;
            item.icon = 'file powerpoint';
        })

        const the_first_pipeline = response.data.length > 0 ? response.data[0].value : null;
        this.setState({
            pipelines: response.data,
            selected_pipeline: the_first_pipeline
        })
    }

    // function to load dataset list from API server
    async loadDataSetsList() {
        const response = await dataset.get('');


        // extract the desired value
        // console.log(response.data)
        response.data.forEach(item => {
            item.key = item.dataset_id;
            item.value = item.dataset_id;
            item.text = item.dataset_name;
            item.icon = 'file powerpoint';
        })

        const the_first_pipeline = response.data.length > 0 ? response.data[0].value : null;
        this.setState({
            datasets: response.data,
            selected_dataset: the_first_pipeline
        })

    }

    // handle job name input from user
    onJobNameChanged(e) {
        this.setState({ name: e.target.value }, () => { this.validate_inputs() })
    }

    // handle jobdescription input from user
    onJobDescriptionChanged(e) {
        this.setState({
            description: e.target.value
        })
    }

    // handle pipeline selection from user
    onPipelineSelected(e, { value }) {
        this.setState({
            selected_pipeline: { value }.value
        });
    }

    // handle dataset selection from user
    onDatasetSelected(e, { value }) {
        this.setState({
            selected_dataset: { value }.value
        })
    }


    // load data from API server
    componentDidMount() {
        this.loadPipelines(this.state.user_name);
        this.loadDataSetsList();
    }


    // update user name when it changed
    componentWillReceiveProps(nextProps) {
        if (nextProps.user_name !== this.state.user_name)
            this.setState({
                user_name: nextProps.user_name
            });
    }

    // reload data when user name changed
    componentWillUpdate(nextProps) {
        if (nextProps.user_name !== this.state.user_name) {
            this.loadPipelines(this.state.user_name);
        }

    }

    // fuction to submit job request
    async onjobSubmit() {
        const formData = new FormData();
        formData.append('pipeline_id', this.state.selected_pipeline);
        formData.append('data_set_id', this.state.selected_dataset);
        formData.append('username', this.props.user_name);
        formData.append('name', this.state.name);
        formData.append('description', this.state.description)

        const config = {
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        };

        startRun.post('', formData, config);

    }

    // when user submit a job
    onFormSubmit(e) {
        e.preventDefault() // Stop form submit

        this.onjobSubmit();
        this.props.onMenuClicked('my_analysis_page');
    }

    validate_inputs() {
        if (this.state.name !== '' && this.state.selected_dataset &&
            this.state.selected_pipeline) {
            this.setState({ is_input_valid: true })
        } else {
            this.setState({ is_input_valid: false })
        }
    }

    onDescriptionChanged(e) {
        this.setState({ description: e.target.value }, () => { this.validate_inputs() })
    }

    fileUpload(data) {
        const url = this.API_config['endpoint'];
        const formData = new FormData();
        formData.append('user_name', data['user_name']);
        formData.append('file_name', data['file_name']);
        formData.append('file', data['file']);
        formData.append('description', data['description']);
        const config = {
            headers: {
                'content-type': 'multipart/form-data'
            }
        }
        return post(url, formData, config)
    };

    render() {
        if (this.state.redirect) {
            return <Redirect to={{
                pathname: '/run_result',
                state: {
                    data: this.state.result_from_server
                }
            }} />
        }

        return (
            <div className="ui container">
                <form onSubmit={this.onFormSubmit} className="ui form">
                    <div className="ui container">
                        <div className="field">
                            <h2> </h2>
                            <h3>Create Analysis</h3>
                        </div>
                        <div className="ui form">
                            <div className="field">
                                <label>Job Name</label>
                                <input type="text" className="ui input"
                                    value={this.state.name}
                                    onChange={this.onJobNameChanged} ></input>
                            </div>
                            <div className="field">
                                <label>Select Dataset</label>
                                <Dropdown placeholder='Select Dataset' fluid search selection
                                    value={this.state.selected_dataset}
                                    options={this.state.datasets}
                                    onChange={this.onDatasetSelected} />
                            </div>
                            <div className="field">
                                <label>Select Pipeline</label>
                                <Dropdown placeholder='Select Dataset' fluid search selection
                                    value={this.state.selected_pipeline}
                                    options={this.state.pipelines}
                                    onChange={this.onPipelineSelected} />
                            </div>
                            <div className="field">
                                <label>description:</label>
                                <textarea value={this.state.description}
                                    onChange={this.onDescriptionChanged}></textarea>
                            </div>
                            <div className="field">
                                <button type="submit" className="ui primary button"
                                    // onClick={() => window.location.href="#" = '/run_result'}
                                    disabled={!this.state.is_input_valid}>
                                    Submit Job
                                </button>
                            </div>
                        </div>
                    </div>
                </form >
            </div>

        )
    }
}

export default SubmitJob