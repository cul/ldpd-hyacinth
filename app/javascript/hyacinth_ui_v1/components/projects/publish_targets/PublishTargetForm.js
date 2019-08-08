import React from 'react';
import { Form, Collapse } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from 'immer';

import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import hyacinthApi from '../../../util/hyacinth_api';
import InputGroup from '../../ui/forms/InputGroup';
import Label from '../../ui/forms/Label';
import FormButtons from '../../ui/forms/FormButtons';
import NumberInput from '../../ui/forms/inputs/NumberInput';
import TextInput from '../../ui/forms/inputs/TextInput';
import Checkbox from '../../ui/forms/inputs/Checkbox';

class PublishTargetForm extends React.Component {
  state = {
    formType: 'new',
    projectStringKey: '',
    publishTarget: {
      displayLabel: '',
      stringKey: '',
      publishUrl: '',
      apiKey: '',
      isAllowedDoiTarget: false,
      doiPriority: 100,
    },
  }

  componentDidMount() {
    const { formType, projectStringKey, stringKey } = this.props;

    if (stringKey) {
      hyacinthApi.get(`/projects/${projectStringKey}/publish_targets/${stringKey}`)
        .then((res) => {
          const { publishTarget } = res.data;

          this.setState(produce((draft) => {
            draft.publishTarget = publishTarget;
          }));
        });
    }

    this.setState(produce((draft) => {
      draft.formType = formType;
      draft.projectStringKey = projectStringKey;
    }));
  }

  onSubmitHandler = () => {
    const { formType, projectStringKey, publishTarget } = this.state;

    switch (formType) {
      case 'new':
        return hyacinthApi.post(`/projects/${projectStringKey}/publish_targets`, publishTarget)
          .then((res) => {
            const { publishTarget: { stringKey } } = res.data;

            this.props.history.push(`/projects/${projectStringKey}/publish_targets/${stringKey}/edit`);
          });
      case 'edit':
        return hyacinthApi.patch(`/projects/${projectStringKey}/publish_targets/${publishTarget.stringKey}`, publishTarget);
      default:
        return null;
    }
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const {
      match: { params: { projectStringKey, stringKey } },
      history: { push }
    } = this.props;

    hyacinthApi.delete(`/projects/${projectStringKey}/publish_targets/${stringKey}`)
      .then(() => push(`/projects/${projectStringKey}/publish_targets`));
  }

  onChangeHandler = (name, value) => {
    this.setState(produce((draft) => {
      draft.publishTarget[name] = value;
    }));
  }

  render() {
    const {
      formType,
      projectStringKey,
      publishTarget: {
        stringKey, displayLabel, publishUrl, apiKey, doiPriority, isAllowedDoiTarget,
      },
    } = this.state;

    return (
      <div>
        <Form onSubmit={this.onSubmitHandler}>
          <InputGroup>
            <Label>String Key</Label>
            <TextInput
              value={stringKey}
              onChange={v => this.onChangeHandler('stringKey', v)}
              disabled={formType === 'edit'}
            />
          </InputGroup>

          <InputGroup>
            <Label>Display Label</Label>
            <TextInput
              value={displayLabel}
              onChange={v => this.onChangeHandler('displayLabel', v)}
            />
          </InputGroup>

          <InputGroup>
            <Label>Publish URL</Label>
            <TextInput
              value={publishUrl}
              onChange={v => this.onChangeHandler('publishUrl', v)}
            />
          </InputGroup>

          <InputGroup>
            <Label>API Key</Label>
            <TextInput
              value={apiKey}
              onChange={v => this.onChangeHandler('apiKey', v)}
            />
          </InputGroup>

          <InputGroup>
            <Label>Allowed to be set as DOI target?</Label>
            <Checkbox
              value={isAllowedDoiTarget}
              onChange={v => this.onChangeHandler('isAllowedDoiTarget', v)}
            />
          </InputGroup>

          <Collapse in={isAllowedDoiTarget}>
            <div>
              <InputGroup>
                <Label>DOI Priority</Label>
                <NumberInput
                  value={doiPriority}
                  onChange={v => this.onChangeHandler('doiPriority', v)}
                />
              </InputGroup>
            </div>
          </Collapse>

          <FormButtons
            formType={formType}
            cancelTo={`/projects/${projectStringKey}/publish_targets`}
            onSave={this.onSubmitHandler}
            onDelete={this.onDeleteHandler}
          />
        </Form>
      </div>
    );
  }
}

export default withRouter(withErrorHandler(PublishTargetForm, hyacinthApi));
