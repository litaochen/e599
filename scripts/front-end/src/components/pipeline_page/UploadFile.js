import React from 'react'

import pipeline from '../../apis/PipelineAPI';

class UplaodFile extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            file_name: '',
            file: '',
            description: '',
            is_input_valid: false
        }

        this.validate_inputs = this.validate_inputs.bind(this);
        this.onFormSubmit = this.onFormSubmit.bind(this);
        this.onFileChange = this.onFileChange.bind(this);
        this.onDescriptionChange = this.onDescriptionChange.bind(this);
        this.fileUpload = this.fileUpload.bind(this);
    }

    validate_inputs() {
        if (this.state.file_name &&
            this.state.description) {
            this.setState({ is_input_valid: true })
        } else {
            this.setState({ is_input_valid: false })
        }
    }

    async onFormSubmit(e) {
        e.preventDefault() // Stop form submit

        // ask server to save the pipeline file
        await this.fileUpload(this.state).then((response) => {
            console.log(response.data);
        });

        // ask parent to re-render
        this.props.refreshData(this.props.user_name)
        this.props.close()
    }

    onFileChange(e) {
        var pipeline_file_pattern = /.*.cppipe/
        if (!e.target.files[0].name.match(pipeline_file_pattern)) {
            alert("invalid pipeline file")
            this.setState({ is_input_valid: false });
        } else {
            // setState is async call. need to remember the file here
            // also handled the situation that there is space in file name
            const the_file = e.target.files[0];
            this.setState({ file: the_file });
            this.setState({ file_name: the_file.name.replace(/\s/g, "-") }, () => { this.validate_inputs() });
        }

    }

    onDescriptionChange(e) {
        this.setState({ description: e.target.value }, () => { this.validate_inputs() })
    }

    fileUpload(data) {
        const formData = new FormData();
        formData.append('username', this.props.user_name);
        formData.append('filename', data['file_name']);
        formData.append('data', data['file']);
        formData.append('description', data['description']);
        // const config = {
        //     headers: {
        //         'content-type': 'multipart/form-data'
        //     }
        // }
        return pipeline.post('upload/', formData)
        // return post(url, formData, config)
    }

    render() {
        return (
            <form onSubmit={this.onFormSubmit} className="ui form">
                <h3>Upload Your CellProfiler Pipline</h3>
                <div className="ui container">
                    <div className="ui form">
                        <div className="field">
                            <input type="file" className="ui input"
                                onChange={this.onFileChange} />
                        </div>
                        <div className="field">
                            <label>description:</label>
                            <textarea value={this.state.description}
                                onChange={this.onDescriptionChange}></textarea>
                        </div>
                        <div className="field">
                            <button type="submit" className="ui primary button"
                                disabled={!this.state.is_input_valid}>
                                Upload
                                </button>
                        </div>
                    </div>
                </div>
            </form >
        )
    }
}

export default UplaodFile