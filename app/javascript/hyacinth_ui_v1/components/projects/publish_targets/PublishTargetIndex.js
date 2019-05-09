import React from 'react';
import { Link } from 'react-router-dom';
import { Table, Button } from 'react-bootstrap';
import producer from 'immer';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { LinkContainer } from 'react-router-bootstrap';

import ProjectSubHeading from 'hyacinth_ui_v1/hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';

export default class FieldSetIndex extends React.Component {
  state = {
    publishTargets: [],
  }

  componentDidMount() {
    hyacinthApi.get(`/projects/${this.props.match.params.string_key}/publish_targets`)
      .then((res) => {
        this.setState(producer((draft) => { draft.publishTargets = res.data.publish_targets; }));
      });
  }

  render() {
    let rows = <tr><td colSpan="4">No publish targets have been defined</td></tr>;

    if (this.state.publishTargets.length > 0) {
      rows = this.state.publishTargets.map(publish_target => (
        <tr key={publish_target.string_key}>
          <td><Link to={`/projects/${this.props.match.params.string_key}/publish_targets/${publish_target.string_key}/edit`} href="#">{publish_target.display_label}</Link></td>
          <td>{publish_target.string_key}</td>
          <td>{publish_target.publish_url}</td>
          <td>{publish_target.api_key}</td>
        </tr>
      ));
    }

    return (
      <>
        <ProjectSubHeading>Publish Targets</ProjectSubHeading>

        <Table hover>
          <thead>
            <tr>
              <th>Display Label</th>
              <th>String Key</th>
              <th>Publish URL</th>
              <th>API Key</th>
            </tr>
          </thead>
          <tbody>
            {rows}
            <tr>
              <td className="text-center" colSpan="4">
                <LinkContainer to={`${this.props.match.url}/new`}>
                  <Button size="sm" variant="link">
                    <FontAwesomeIcon icon="plus" />
                    {' '}
Add New Publish Target
                  </Button>
                </LinkContainer>
              </td>
            </tr>
          </tbody>
        </Table>
      </>
    );
  }
}
