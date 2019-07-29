import React from 'react';
import produce from 'immer';
import { capitalize } from 'lodash';
import { withRouter } from 'react-router-dom';

import ContextualNavbar from '../../layout/ContextualNavbar';
import { projects } from '../../../util/hyacinth_api';
import MetadataForm from '../metadata/MetadataForm';
import DigitalObjectSummary from '../DigitalObjectSummary';

class AggregatorNew extends React.PureComponent {
  state = {
    loaded: false,
    data: {
      serializationVersion: '1',
      projects: [{
        stringKey: '',
      }],
      digitalObjectType: '',
      dynamicFieldData: {},
      identifiers: [],
    },
  }

  componentDidMount = () => {
    const { project, digitalObjectType } = this.props;

    // Get Project Display Label and adding props to state
    projects.get(project).then((res) => {
      const { project: { stringKey, displayLabel } } = res.data;
      this.setState(produce((draft) => {
        draft.data.digitalObjectType = digitalObjectType;
        draft.data.projects[0] = { stringKey, displayLabel };
        draft.loaded = true;
      }));
    });
  }

  render() {
    const { data, loaded } = this.state;

    return (
      <>
        <ContextualNavbar
          title={`New ${capitalize(data.digitalObjectType)}`}
          rightHandLinks={[{ link: '/digital_objects', label: 'Back to Digital Objects' }]}
        />

        {
          loaded && (
            <>
              <DigitalObjectSummary data={data} />
              <MetadataForm formType="new" data={data} />
            </>
          )
        }
      </>
    );
  }
}

export default withRouter(AggregatorNew);
