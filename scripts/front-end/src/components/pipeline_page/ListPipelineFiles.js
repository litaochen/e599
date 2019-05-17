import React from 'react';
import fileDownload from 'js-file-download';

import { confirmAlert } from 'react-confirm-alert';

import { dynamicSort } from '../../utils/Utils';
import { beautifyDate } from '../../utils/Utils';
import pipeline from '../../apis/PipelineAPI';

import '../../css/react-confirm-alert.css';


class ListPipelineFiles extends React.Component {
    // constructor will only be called once
    constructor(props) {
        super(props);
        this.state = {
            pipelines: this.props.data,
            filename_desc_sort: true,
            date_desc_sort: true,
            user_desc_sort: true,
            description_desc_sort: true
        };

        // bind functions
        this.CreatList = this.CreatList.bind(this);
        this.onSortClicked = this.onSortClicked.bind(this);
        this.confirmToDelete = this.confirmToDelete.bind(this);
        this.onDeleteClicked = this.onDeleteClicked.bind(this);
    };

    // process data when props changed
    componentDidUpdate(prevProps) {
        // Typical usage (don't forget to compare props):
        if (this.props.data !== prevProps.data) {
            this.props.data.sort(dynamicSort('-date'));
            this.setState({
                pipelines: this.props.data.forEach((item) =>
                    item.date = beautifyDate(item.date))
            })
        }
    }

    // handle sort by click
    onSortClicked(field) {
        const the_state_name = field + '_desc_sort';
        const current_state = this.state[the_state_name]
        if (current_state) {
            this.setState({
                pipelines: this.props.data.sort(dynamicSort('-' + field)),
                [the_state_name]: !current_state
            });
        }
        else {
            this.setState({
                pipelines: this.props.data.sort(dynamicSort(field)),
                [the_state_name]: !current_state
            });
        }
    }

    // handle pipeline file download
    async onDownloadClicked(the_pipeline_id, filename) {
        const response = await pipeline.get('download/', {
            params: {
                pipeline_id: the_pipeline_id
            }
        });

        // add ".cppipe" extension if not there
        const the_file_name = filename.slice(-6) === 'cppipe' ? filename : filename + '.cppipe'
        fileDownload(response.data, the_file_name)
    }


    // ask user to confirm deletion
    confirmToDelete(the_pipeline_id) {
        confirmAlert({
            title: 'Confirm to delete',
            message: 'Are you sure to delete the pipeline?',
            buttons: [
                {
                    label: 'Yes',
                    onClick: () => this.onDeleteClicked(the_pipeline_id)
                },
                {
                    label: 'No',
                    onClick: () => { }
                }
            ]
        });
    }


    // handle pipeline file delete
    async onDeleteClicked(the_pipeline_id) {
        await pipeline.delete('delete/', {
            params: {
                script_id: the_pipeline_id
            }
        })

        // ask parent to re-render
        this.props.refreshData(this.props.user_name)

    }

    CreatList() {
        return (
            <table className="ui single line table">
                <thead>
                    <tr>
                        <th><a href="#" onClick={() => this.onSortClicked('filename')}>File Name</a></th>
                        <th><a href="#" onClick={() => this.onSortClicked('date')}>Upload Date</a></th>
                        <th><a href="#" onClick={() => this.onSortClicked('username')}>User Name</a></th>
                        <th><a href="#" onClick={() => this.onSortClicked('description')}>Description</a></th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    {
                        this.props.data.map(item => {
                            return (
                                <tr key={item._id}>
                                    <td> {item.filename} </td>
                                    <td> {item.date}</td>
                                    <td>{item.username}</td>
                                    <td>{item.description}</td>
                                    <td>
                                        <button className="ui basic green button"
                                            onClick={() => this.onDownloadClicked(item._id, item.filename)}>
                                            Download
                                        </button>
                                        <button className="ui basic red button"
                                            onClick={() => this.confirmToDelete(item._id)}
                                        >Delete</button>
                                    </td>
                                </tr>
                            )
                        })
                    }
                </tbody>
            </table>
        )
    };

    render() {
        return (
            <div className="ui container" >
                <div>
                    <h3>Available CellProfiler Pipelines</h3>
                </div>
                {this.CreatList()}
            </div>
        )
    }
};


export default ListPipelineFiles;

