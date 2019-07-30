import React from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from 'immer';

import hyacinthApi, { vocabulary } from '../../util/hyacinth_api';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';
import InputGroup from '../ui/forms/InputGroup';
import Label from '../ui/forms/Label';
import TextInput from '../ui/forms/inputs/TextInput';
import PlainText from '../ui/forms/inputs/PlainText';
import FormButtons from '../ui/forms/FormButtons';

class ControlledVocabularyForm extends React.Component {
  state = {
    formType: '',
    controlledVocabulary: {
      stringKey: '',
      label: '',
      customFields: {},
    },
  }

  componentDidMount() {
    const { formType, stringKey } = this.props;

    if (stringKey) {
      vocabulary(stringKey).get()
        .then((res) => {
          this.setState(produce((draft) => {
            draft.controlledVocabulary = res.data.vocabulary;
          }));
        });
    }

    this.setState(produce((draft) => {
      draft.formType = formType;
    }));
  }

  onSubmitHandler = () => {
    const { formType, controlledVocabulary: { stringKey }, controlledVocabulary } = this.state;
    const { history: { push } } = this.props;

    switch (formType) {
      case 'new':
        return hyacinthApi.post('/vocabularies', { vocabulary: controlledVocabulary })
          .then((res) => {
            const { vocabulary: { stringKey: newStringKey } } = res.data;

            push(`/controlled_vocabularies/${newStringKey}/edit`);
          });
      case 'edit':
        return hyacinthApi.patch(`/vocabularies/${stringKey}`, { vocabulary: controlledVocabulary });
      default:
        return null;
    }
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { controlledVocabulary: { stringKey } } = this.state;
    const { history: { push } } = this.props;

    hyacinthApi.delete(`/controlled_vocabularies/${stringKey}`)
      .then(() => push('/controlled_vocabularies'));
  }

  onChangeHandler = (name, value) => {
    this.setState(produce((draft) => { draft.controlledVocabulary[name] = value; }));
  }

  render() {
    const { formType, controlledVocabulary: { label, stringKey } } = this.state;

    return (
      <Form onSubmit={this.onSubmitHandler}>
        <InputGroup>
          <Label>String Key</Label>
          {
            formType === 'new'
              ? <TextInput value={stringKey} onChange={v => this.onChangeHandler('stringKey', v)} />
              : <PlainText value={stringKey} />
          }
        </InputGroup>

        <InputGroup>
          <Label>Label</Label>
          <TextInput
            value={label}
            onChange={v => this.onChangeHandler('label', v)}
          />
        </InputGroup>

        <FormButtons
          formType={formType}
          cancelTo={`/controlled_vocabularies/${stringKey}`}
          onDelete={this.onDeleteHandler}
          onSave={this.onSubmitHandler}
        />
      </Form>

    );
  }
}

ControlledVocabularyForm.defaultProps = {
  stringKey: null,
};

ControlledVocabularyForm.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  stringKey: PropTypes.string,
};

export default withRouter(withErrorHandler(ControlledVocabularyForm, hyacinthApi));
