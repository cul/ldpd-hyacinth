import React from 'react';
import produce from 'immer';
import { withRouter } from 'react-router-dom';

import { digitalObject } from '../../util/hyacinth_api';
import Tab from '../ui/tabs/Tab';
import Tabs from '../ui/tabs/Tabs';
import TabBody from '../ui/tabs/TabBody';
import ContextualNavbar from '../layout/ContextualNavbar';
import DigitalObjectSummary from './DigitalObjectSummary';

const digitalObjectInterface = WrappedComponent => class extends React.Component {
  state = {
    digitalObjectData: null,
  };

  componentDidMount() {
    const { match: { params: { id } } } = this.props;

    digitalObject.get(id)
      .then((res) => {
        this.setState(produce((draft) => {
          console.log('reloaded digital object data');
          draft.digitalObjectData = res.data.digitalObject;
        }));
      });
  }

  render() {
    const { digitalObjectData: data } = this.state;
    const { match: { params: { id } } } = this.props;

    return (
      <>
        {
          data && (
            <div className="digital-object-interface">
              <ContextualNavbar
                title={`Item | ${data.dynamicFieldData.title[0].titleSortPortion}`}
              />

              <DigitalObjectSummary data={data} />

              <Tabs>
                <Tab to={`/digital_objects/${id}/system_data`} name="System Data" />
                <Tab to={`/digital_objects/${id}/metadata`} name="Metadata" />
                <Tab to={`/digital_objects/${id}/rights`} name="Rights" />

                {
                  (data.digitalObjectType === 'item') && (
                    <Tab to={`/digital_objects/${id}/children`} name="Manage Child Assets" />
                  )
                }

                {
                  (data.digitalObjectType === 'asset') && (
                    <Tab to={`/digital_objects/${id}/parents`} name="Parents" />
                  )
                }

                <Tab to={`/digital_objects/${id}/assignment`} name="Assign This" />
                <Tab to={`/digital_objects/${id}/preserve_publish`} name="Preserve/Publish" />
              </Tabs>

              <TabBody>
                <WrappedComponent data={data} {...this.props} />
              </TabBody>
            </div>
          )
        }
      </>
    );
  }
};

export default (...args) => withRouter(digitalObjectInterface(...args));
