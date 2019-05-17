// a component to allow use to specify feature criteria
// and filter the runs based on the criteria supplied by user

import React from 'react';
import { Dropdown } from 'semantic-ui-react';
import globalKeys from '../../apis/GetGlobalKeysAPI';


class RunsByFeatureFilter extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            wellLevelFeatrues: [{ key: 'Count_IdentifyPrimaryObjects', value: 'Count_IdentifyPrimaryObjects', text: 'Count_IdentifyPrimaryObjects' }, { key: 'Count_IdentifyPrimaryObjects-2', value: 'Count_IdentifyPrimaryObjects-2', text: 'Count_IdentifyPrimaryObjects-2' }],
            cellLevelFeatures: [{ key: 'Intensity_IntegratedIntensity_DAPI', value: 'Intensity_IntegratedIntensity_DAPI', text: 'Intensity_IntegratedIntensity_DAPI' }, { key: 'Intensity_IntegratedIntensity_DAPI-2', value: 'Intensity_IntegratedIntensity_DAPI-2', text: 'Intensity_IntegratedIntensity_DAPI-2' }],
            Max_num_of_features: 5,
            well_level_feature_criteria: [],
            cell_level_feature_criteria: []
        };

        this.getGlobalKeys = this.getGlobalKeys.bind(this);
        this.onFeatureSelected = this.onFeatureSelected.bind(this);
        this.onRangeSet = this.onRangeSet.bind(this);

        this.onAddFeatureFilter = this.onAddFeatureFilter.bind(this);
        this.onDeleteFeatureFilter = this.onDeleteFeatureFilter.bind(this);

        this.buildFeatureFilterList = this.buildFeatureFilterList.bind(this);

        this.onApplyFilter = this.onApplyFilter.bind(this)
    };

    componentDidMount() {
        this.getGlobalKeys();
    }

    // get global keys from API server
    async getGlobalKeys() {
        const response = await globalKeys.get('', {

        });

        // check if we get the feature data
        if (!Array.isArray(response.data) || response.data.length <= 0)
            return

        // format the data for the dropdown list
        const cell_level_features = response.data[0].cell.map(item => {
            return {
                key: item,
                value: item,
                text: item
            }
        });
        const well_level_features = response.data[0].well.map(item => {
            return {
                key: item,
                value: item,
                text: item
            }
        });

        this.setState({
            wellLevelFeatrues: well_level_features,
            cellLevelFeatures: cell_level_features
        })
    }


    // update state when user add new feature filter
    // the feature type must be the corresponding key name in the state
    onAddFeatureFilter(feature_type) {
        const num_of_filters = this.state[feature_type].length;

        if (num_of_filters >= this.state.Max_num_of_features)
            return

        let default_feature = { min: '', max: '' };
        if (feature_type === 'well_level_feature_criteria')
            default_feature.key = this.state['wellLevelFeatrues'][0].value
        else
            default_feature.key = this.state['cellLevelFeatures'][0].value

        this.setState(prevState => ({
            [feature_type]: [...prevState[feature_type], default_feature]
        }));

    }

    // remove filter
    // the feature type must be the corresponding key name in the state
    onDeleteFeatureFilter(feature_type, the_index) {
        const newFeatureCriteria =
            [...this.state[feature_type]].filter((item, index) => index !== the_index);

        this.setState({
            [feature_type]: newFeatureCriteria
        })
    }

    // update state when user select well level feature
    onFeatureSelected(feture_type, index, e, { value }) {
        const newFeatureCriteria = [...this.state[feture_type]];
        newFeatureCriteria[index].key = { value }.value;

        this.setState({
            [feture_type]: newFeatureCriteria
        })
    }

    // update state when user set range (min or max) on a feature
    // this method handle all the number fields from well level and cell level
    // make sure you pass the correct arguments
    onRangeSet(feature_type, boundary, index, e) {
        const newFeatureCriteria = [...this.state[feature_type]];
        const the_value = parseFloat(e.target.value);
        if (isNaN(the_value)) {
            alert("Invalid range. Only numbers allowed")
        }
        else
            newFeatureCriteria[index][boundary] = parseFloat(e.target.value);

        this.setState({
            [feature_type]: newFeatureCriteria
        })
    }

    // apply filters
    onApplyFilter() {
        let cell_level_feature_criteria = this.state.cell_level_feature_criteria.filter(item => {
            return item.min !== '' && item.max !== '';
        });
        let well_level_feature_criteria = this.state.well_level_feature_criteria.filter(item => {
            return item.min !== '' && item.max !== '';
        })

        const the_criteria = {
            cell_level_summary: cell_level_feature_criteria,
            well_level_summary: well_level_feature_criteria
        }

        this.props.applyFilters(the_criteria);
    }

    // build feature filter list
    buildFeatureFilterList(feature_type) {
        const featureFilters = [];

        for (var i = 0; i < this.state[feature_type].length; i += 1) {
            const the_index = i;

            featureFilters.push(
                <div className="ui form" key={feature_type + i}>
                    <div className="three fields">
                        <Dropdown placeholder='Select Dataset' fluid search selection
                            value={this.state[feature_type][the_index].key}
                            options={feature_type === 'well_level_feature_criteria' ? this.state.wellLevelFeatrues : this.state.cellLevelFeatures}
                            onChange={(e, { value }) =>
                                this.onFeatureSelected(feature_type, the_index, e, { value })} />
                        <div className="field">
                            <input className="ui input"
                                key={feature_type + i + 'min'}
                                type="text" placeholder="min"
                                value={this.state[feature_type][the_index].min}
                                onChange={(e) => this.onRangeSet(feature_type, 'min', the_index, e)}
                            />
                        </div>
                        <div className="field">
                            <input className="ui input"
                                key={feature_type + i + 'max'}
                                type="text" placeholder="max"
                                value={this.state[feature_type][the_index].max}
                                onChange={(e) => this.onRangeSet(feature_type, 'max', the_index, e)}
                            />
                        </div>
                        <div className="field"><i className="trash alternate large icon"
                            onClick={() =>
                                this.onDeleteFeatureFilter(feature_type, the_index)}></i></div>
                    </div>
                </div>

            );
        };

        if (this.state[feature_type].length === this.state.Max_num_of_features) {
            featureFilters.push(
                <div key={feature_type + i + 'max_reached'}>
                    <label className="ui label">Maximum {this.state.Max_num_of_features} criteria allowed</label>
                </div>
            )
        };

        return (
            <div>
                {featureFilters}
            </div>
        )
    }

    render() {
        return (
            <div className="ui container">
                <div className="ui segment">
                    <div className="ui two column very relaxed grid">
                        <div className="column">
                            <div className="ui container">
                                <h4>Well Level Feature Filter</h4>
                                {this.buildFeatureFilterList('well_level_feature_criteria')}
                                <button className="ui primary basic button"
                                    onClick={() => this.onAddFeatureFilter('well_level_feature_criteria')}>Add Filter</button>
                            </div>
                        </div>
                        <div className="column">
                            <div className="ui container">
                                <h4>Cell Level Feature Filter</h4>
                                {this.buildFeatureFilterList('cell_level_feature_criteria')}
                                <button className="ui primary basic button"
                                    onClick={() => this.onAddFeatureFilter('cell_level_feature_criteria')}>Add Filter</button>
                            </div>
                        </div>
                    </div>
                    <div className="ui vertical divider">AND</div>
                    <h2> </h2>
                    <div className="ui container">
                        <button className="ui primary button"
                            onClick={() => this.onApplyFilter()}>Filter runs</button>
                    </div>
                </div>
            </div>

        );
    }

}

export default RunsByFeatureFilter;