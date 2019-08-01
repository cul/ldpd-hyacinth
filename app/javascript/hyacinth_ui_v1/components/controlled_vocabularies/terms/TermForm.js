import React from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from 'immer';

import hyacinthApi, { terms } from '../../../util/hyacinth_api';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import InputGroup from '../../ui/forms/InputGroup';
import Label from '../../ui/forms/Label';
import TextInput from '../../ui/forms/inputs/TextInput';
import TextInputWithAddAndRemove from '../../ui/forms/inputs/TextInputWithAddAndRemove';
import SelectInput from '../../ui/forms/inputs/SelectInput';
import NumberInput from '../../ui/forms/inputs/NumberInput';
import ReadOnlyInput from '../../ui/forms/inputs/ReadOnlyInput';
import PlainText from '../../ui/forms/inputs/PlainText';
import FormButtons from '../../ui/forms/FormButtons';

const types = ['external', 'local', 'temporary'];

class TermForm extends React.Component {
  state = {
    formType: '',
    term: {
      uri: '',
      authority: '',
      termType: '',
      prefLabel: '',
      altLabels: [],
    },
  }

  componentDidMount() {
    const { formType, term } = this.props;

    if (term) {
      this.setState(produce((draft) => {
        draft.term = term;
      }));
    }

    this.setState(produce((draft) => {
      draft.formType = formType;
    }));
  }

  onSubmitHandler = (event) => {

    const { formType, term: { uri }, term } = this.state;
    const { history: { push }, vocabulary: { stringKey } } = this.props;

    switch (formType) {
      case 'new':
        return terms.create(stringKey, { term })
          .then((res) => {
            const { term: { uri: newURI } } = res.data;

            push(`/controlled_vocabularies/${stringKey}/terms/${encodeURIComponent(newURI)}/edit`);
          });
      case 'edit':
        return terms.update(stringKey, encodeURIComponent(uri), { term });
      default:
        return null;
    }
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const {
      match: { params: { stringKey, uri } },
      history: { push }
    } = this.props;

    terms.delete(stringKey, uri)
      .then(() => push(`/controlled_vocabularies/${stringKey}`));
  }

  onChangeHandler = (name, value) => {
    this.setState(produce((draft) => { draft.term[name] = value; }));
  }

  render() {
    const { match: { params: { stringKey } } } = this.props;
    const {
      formType,
      term,
      term: {
        prefLabel, uri, authority, altLabels, termType,
      },
    } = this.state;

    const { vocabulary } = this.props;

    return (
      <Form onSubmit={this.onSubmitHandler}>
        <InputGroup>
          <Label>Term Type</Label>
          {
            formType === 'new'
              ? <SelectInput value={termType} onChange={v => this.onChangeHandler('termType', v)} options={types.map(t => ({ label: t, value: t }))} />
              : <PlainText value={termType} />
          }
        </InputGroup>

        <InputGroup>
          <Label>URI</Label>
          {
            (() => {
              if (formType === 'edit') {
                return <PlainText value={uri} />;
              } else if (termType === 'external' || termType === '') {
                return <TextInput value={uri} onChange={v => this.onChangeHandler('uri', v)} />;
              } else {
                return <ReadOnlyInput value={uri} />;
              }
            })()
          }
        </InputGroup>

        <InputGroup>
          <Label>Pref Label</Label>
          {
            termType === 'temporary' && formType !== 'new'
              ? <PlainText value={prefLabel} />
              : <TextInput value={prefLabel} onChange={v => this.onChangeHandler('prefLabel', v)} />
          }
        </InputGroup>

        {
          termType !== 'temporary' && (
            <InputGroup>
              <Label>Alternative Labels</Label>
              <TextInputWithAddAndRemove values={altLabels} onChange={v => this.onChangeHandler('altLabels', v)} />
            </InputGroup>
          )
        }

        <InputGroup>
          <Label>Authority</Label>
          <TextInput value={authority} onChange={v => this.onChangeHandler('authority', v)} />
        </InputGroup>

        {
          Object.keys(vocabulary.customFields).map((k) => {
            const { label, dataType } = vocabulary.customFields[k];

            let field = '';

            switch (dataType) {
              case 'string':
                field = <TextInput value={term[k]} onChange={v => this.onChangeHandler(k, v)} />;
                break;
              case 'integer':
                field = <NumberInput value={term[k]} onChange={v => this.onChangeHandler(k, v)} />;
                break;
              default:
                field = '';
                break;
            }

            return (
              <InputGroup>
                <Label>{label}</Label>
                { field }
              </InputGroup>
            );
          })
        }

        <FormButtons
          formType={formType}
          cancelTo={`/controlled_vocabularies/${stringKey}`}
          onSave={this.onSubmitHandler}
          onDelete={this.onDeleteHandler}
        />
      </Form>
    );
  }
}

TermForm.defaultProps = {
  stringKey: null,
};

TermForm.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  stringKey: PropTypes.string,
};

export default withRouter(withErrorHandler(TermForm, hyacinthApi));
