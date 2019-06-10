import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import { Table, Button } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
  snakeCase, lowerFirst, words, last,
} from 'lodash';

import hyacinthApi from '../../../util/hyacinth_api';

class DynamicFieldsAndGroupsTable extends React.Component {
  updateSortOrder(type, id, sortOrder) {
    const data = { [lowerFirst(type)]: { sortOrder } };
    const { history: { push } } = this.props;

    hyacinthApi.patch(`/${snakeCase(type)}s/${id}`, data)
      .then(() => push('/dynamic_fields'));
  }

  render() {
    const { rows, ...rest } = this.props;

    let body = null;

    if (!Array.isArray(rows) || !rows.length) {
      body = <p>Child elements have not been defined.</p>;
    } else {
      body = (
        <Table striped {...rest}>
          <tbody>
            {
              rows.map((fieldOrGroup, index) => {
                const sortUp = (index === 0) ? null : Math.max(0, rows[index - 1].sortOrder - 1);
                const sortDown = (index === rows.length - 1) ? null : rows[index + 1].sortOrder + 1;

                const { displayLabel, id, type } = fieldOrGroup;

                return (
                  <tr key={`${type}_${id}`}>
                    <td>{displayLabel}</td>
                    <td><span className="badge badge-secondary">{last(words(type))}</span></td>
                    <td>
                      <Button className="p-0" variant="link" onClick={() => this.updateSortOrder(type, id, sortUp)} disabled={sortUp === null}>
                        <FontAwesomeIcon icon={['far', 'caret-square-up']} size="lg" />
                      </Button>
                      {' '}
                      <Button className="p-0" variant="link" onClick={() => this.updateSortOrder(type, id, sortDown)} disabled={sortDown === null}>
                        <FontAwesomeIcon icon={['far', 'caret-square-down']} size="lg" />
                      </Button>
                    </td>
                    <td>
                      <Link to={`/${snakeCase(type)}s/${id}/edit`}>
                        <FontAwesomeIcon icon="pen" />
                      </Link>
                    </td>
                  </tr>
                );
              })
            }
          </tbody>
        </Table>
      );
    }
    return (body);
  }
}

DynamicFieldsAndGroupsTable.defaultProps = {
  rows: [],
};

DynamicFieldsAndGroupsTable.propTypes = {
  rows: PropTypes.arrayOf(
    PropTypes.shape({
      displayLabel: PropTypes.string.isRequired,
      id: PropTypes.number.isRequired,
      type: PropTypes.string.isRequired,
      sortOrder: PropTypes.number.isRequired,
    }),
  ),
};

export default DynamicFieldsAndGroupsTable;