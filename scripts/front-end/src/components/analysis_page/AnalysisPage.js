import React from 'react';

import ListRuns from './ListRuns';
import RunByFeatureFilter from './RunsByFeatureFilter';

import { beautifyDate } from '../../utils/Utils';
import { dynamicSort } from '../../utils/Utils';
import runs from '../../apis/JobAPI';
import runDelete from '../../apis/RunDeleteAPI';


// import stylesheet
import '../../css/style.css';


class AnalysisPage extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            user_name: this.props.user_name,
            runs: [],
            filters_applied: false
        };

        // bind functions
        this.refreshData = this.refreshData.bind(this);
        this.applyFilters = this.applyFilters.bind(this);
        this.onDeleteRunClicked = this.onDeleteRunClicked.bind(this);
        this.beautifyRunInfo = this.beautifyRunInfo.bind(this);
    };

    // get data from API server
    async refreshData(user_name) {
        let response = {};
        if (user_name === '')
            response = await runs.get('');
        else
            response = await runs.get('', {
                params: {
                    username: user_name
                }
            });

        if (Array.isArray(response.data)) {
            this.beautifyRunInfo(response);
            this.setState({ runs: response.data })
        }
    }

    // handle run deletion
    async onDeleteRunClicked(the_run_id) {
        await runDelete.delete('delete/', {
            params: {
                run_id: the_run_id
            }
        })

        this.refreshData(this.state.user_name)
    }

    // update run info when user apply filters
    async applyFilters(the_criteria) {
        const response = await runs.post('/search/', the_criteria, {
            headers: {
                'Content-Type': 'application/json'
            }
        })

        if (!Array.isArray(response.data)) {
            this.setState({
                filters_applied: true,
                runs: []
            })
        } else {
            this.beautifyRunInfo(response);
            this.setState({
                filters_applied: true,
                runs: response.data
            })
        }
    }


    beautifyRunInfo(response) {
        // sort the runs by submit date desc
        response.data.sort(dynamicSort('-start_date'));

        // add the missing info to the response data and beautify date data from API
        response.data.forEach(element => {
            if (element.name === '')
                element.name = 'Mock run name';
            if (element.description === '')
                element.description = 'Mock run description';
            if ('start_date' in element && element.start_date.length === 14)
                element.start_date = beautifyDate(element.start_date);
            if ('end_date' in element && element.end_date.length === 14)
                element.end_date = beautifyDate(element.end_date)
        });
    }

    // load data from server
    componentDidMount() {
        this.refreshData(this.state.user_name);
        this.setState({
            filters_applied: false
        })
    }


    // update page when new user-name passed in
    componentWillReceiveProps(nextProps) {
        if (nextProps.user_name !== this.state.user_name) {
            this.setState({
                user_name: nextProps.user_name
            })
        }

        this.refreshData(nextProps.user_name);
    }

    render() {
        return (
            <div className="ui container" style={{ "marginTop": 30 }}>
                <h3>Filter runs by extracted features</h3>
                <RunByFeatureFilter applyFilters={this.applyFilters} />
                <h3>Analysis Job History</h3>
                <div className="ui container segment">
                    <ListRuns data={this.state.runs} filters_applied={this.state.filters_applied}
                        onMenuClicked={this.props.onMenuClicked}
                        onDeleteRunClicked={this.onDeleteRunClicked} />
                </div>
            </div>

        )
    }
};

export default AnalysisPage