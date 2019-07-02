import React from 'react';
import produce from 'immer';
import { capitalize } from 'lodash';

import ContextualNavbar from '../../layout/ContextualNavbar';
import hyacinthApi, { digitalObject, projects } from '../../../util/hyacinth_api';
import MetadataForm from '../metadata/MetadataForm';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import DigitalObjectSummary from '../DigitalObjectSummary';

class AggregatorNew extends React.PureComponent {
  state = {
    loaded: false,
    digitalObjectDataJson: {
      serializationVersion: '1',
      projects: [{
        stringKey: '',
      }],
      digitalObjectType: '',
      dynamicFieldData: {},
    },
  }

  componentDidMount = () => {
    const { project, digitalObjectType } = this.props;

    // Get Project Display Label and adding props to state
    projects.get(project).then((res) => {
      const { project: { stringKey, displayLabel } } = res.data;
      this.setState(produce((draft) => {
        draft.digitalObjectDataJson.digitalObjectType = digitalObjectType;
        draft.digitalObjectDataJson.projects[0] = { stringKey, displayLabel };
        draft.loaded = true;
      }));
    });
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const { digitalObjectDataJson: data } = this.state;
    const { history: { push } } = this.props;

    digitalObject.create(data)
      .then(res => push(`/digital_objects/${res.data.id}/edit`));
  }

  render() {
    const { digitalObjectDataJson: data, loaded } = this.state;

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

export default withErrorHandler(AggregatorNew, hyacinthApi);
