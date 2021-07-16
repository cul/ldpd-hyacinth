import React from 'react';
import PropTypes from 'prop-types';
import { Form, Col } from 'react-bootstrap';

import ProgressButton from './buttons/ProgressButton';
import CancelButton from './buttons/CancelButton';
import DeleteButton from './buttons/DeleteButton';

function FormButtons({
  formType, cancelTo, cancelAction, onDelete, onSave, onSuccess, onError,
}) {
  return (
    <Form.Row>
      <Col sm="auto" className="mr-auto">
        { onDelete && <DeleteButton onClick={onDelete} formType={formType} /> }
      </Col>

      <Col sm="auto">
        { (cancelTo || cancelAction) && <CancelButton to={cancelTo} action={cancelAction} />}
      </Col>

      <Col sm="auto">
        <ProgressButton
          label={formType === 'new' ? 'Create' : 'Update'}
          type="submit"
          loadingLabel={formType === 'new' ? 'Saving...' : 'Updating...'}
          onClick={onSave}
          onSuccess={onSuccess}
          onError={onError}
        />
      </Col>
    </Form.Row>
  );
}

export default FormButtons;

FormButtons.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  cancelTo: PropTypes.string,
  cancelAction: PropTypes.func,
  onDelete: PropTypes.func,
  onSave: PropTypes.func,
  onSuccess: PropTypes.func,
  onError: PropTypes.func,
};

FormButtons.defaultProps = {
  cancelTo: null,
  cancelAction: null,
  onDelete: () => {},
  onSave: () => {},
  onSuccess: () => {},
  onError: () => {},
};
