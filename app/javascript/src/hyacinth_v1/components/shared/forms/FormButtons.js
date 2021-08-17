import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col } from 'react-bootstrap';

import ProgressButton from './buttons/ProgressButton';
import CancelButton from './buttons/CancelButton';
import DeleteButton from './buttons/DeleteButton';

const FormButtons = (props) => {
  const {
    formType, cancelTo, onCancel, onDelete, onDeleteSuccess, onSave, onSaveSuccess, onError,
  } = props;

  return (
    <div className="mt-3">
      <Row>
        <Col className="mr-auto">
          { onDelete && <DeleteButton onClick={onDelete} formType={formType} onSuccess={onDeleteSuccess} /> }
        </Col>

        <Col sm="auto">
          { (cancelTo || onCancel) && <CancelButton to={cancelTo} action={onCancel} />}
        </Col>

        <Col sm="auto">
          <ProgressButton
            label={formType === 'new' ? 'Create' : 'Update'}
            type="submit"
            loadingLabel={formType === 'new' ? 'Saving...' : 'Updating...'}
            onClick={onSave}
            onSuccess={onSaveSuccess}
            onError={onError}
          />
        </Col>
      </Row>
    </div>
  );
};

export default FormButtons;

FormButtons.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  cancelTo: PropTypes.string,
  onCancel: PropTypes.func,
  onDelete: PropTypes.func,
  onDeleteSuccess: PropTypes.func,
  onSave: PropTypes.func,
  onSaveSuccess: PropTypes.func,
  onError: PropTypes.func,
};

FormButtons.defaultProps = {
  cancelTo: null,
  onCancel: null,
  onDelete: null,
  onDeleteSuccess: () => {},
  onSave: () => {},
  onSaveSuccess: () => {},
  onError: () => {},
};
