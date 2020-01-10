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
      primaryProject: {
        stringKey: '',
      },
      digitalObjectType: '',
      dynamicFieldData: {},
      identifiers: [],
    },
  }

  componentDidMount = () => {
    const { primaryProject, digitalObjectType } = this.props;

    // Get Project Display Label and adding props to state
    projects.get(primaryProject).then((res) => {
      const { project: { stringKey, displayLabel } } = res.data;
      this.setState(produce((draft) => {
        draft.data.digitalObjectType = digitalObjectType;
        draft.data.primaryProject = { stringKey, displayLabel };
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
              <DigitalObjectSummary digitalObject={data} />
              <MetadataForm formType="new" digitalObject={data} />
            </>
          )
        }
      </>
    );
  }
}

export default withRouter(AggregatorNew);
