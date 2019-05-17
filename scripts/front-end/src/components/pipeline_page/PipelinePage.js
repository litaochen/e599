import React from 'react';
import Popup from 'reactjs-popup';

import UploadFile from './UploadFile';
import ListPipelineFiles from './ListPipelineFiles';
import pipeline from '../../apis/PipelineAPI'

// import stylesheet
import '../../css/style.css';


class PipelinePage extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            user_name: this.props.user_name,
            pipeline_files: []
        };

        // bind functions
        this.refreshData = this.refreshData.bind(this);
    };

    // update data from server
    async refreshData(user_name) {
        const response = await pipeline.get('', {
            params: {
                username: user_name
            }
        });

        this.setState({ pipeline_files: response.data })
    }



    // load data from server on load
    componentDidMount() {
        // get data from server
        this.refreshData(this.props.user_name);
    }

    // update data when props changed
    componentWillReceiveProps(nextProps) {
        // Typical usage (don't forget to compare props):
        if (this.props.user_name !== nextProps.user_name) {
            this.setState({
                user_name: nextProps.user_name
            })
            this.refreshData(nextProps.user_name);
        }
    }


    render() {
        return (
            <div className="ui container" style={{ "marginTop": 30 }}>
                <div className="ui container segment">
                    <h3>Upload your CellProfiler pipeline file</h3>
                    <Popup trigger={<button className="ui blue button"> Upload Pipeline File </button>} modal>
                        {close => (
                            <div className="modal">
                                <a href="#" className="close" onClick={close}>
                                    &times;
                                </a>
                                <UploadFile user_name={this.state.user_name}
                                    refreshData={this.refreshData} close={close} />
                            </div>
                        )}
                    </Popup>
                </div>

                <div className="ui container segment">
                    <ListPipelineFiles data={this.state.pipeline_files}
                        user_name={this.state.user_name}
                        refreshData={this.refreshData} />
                </div>
            </div>

        )
    }
};

export default PipelinePage