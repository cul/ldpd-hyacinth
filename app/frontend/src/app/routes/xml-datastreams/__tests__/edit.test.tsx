import { describe, it, expect, vi, beforeAll, afterAll, type Mock } from 'vitest';
import {
  buildXmlDatastream,
  mockApiV2,
  renderApp,
  screen,
  userEvent,
} from '@/testing/test-utils';
import XmlDatastreamsEditRoute from '@/app/routes/xml-datastreams/edit';

vi.mock('@monaco-editor/react', async () => {
  return await import('@/testing/mocks/json-editor');
});

beforeAll(() => {
  vi.spyOn(console, 'error').mockImplementation(() => { });
});

afterAll(() => {
  (console.error as Mock).mockRestore();
});

describe('XML Datastreams Edit Route', () => {
  describe('rendering', () => {
    it('should render the form populated with data from the API', async () => {
      const xmlDatastream = buildXmlDatastream({
        stringKey: 'descMetadata',
        displayLabel: 'Descriptive Metadata',
        xmlTranslation: '{"render_if": {"present": ["restriction_on_access"]}}',
      });

      mockApiV2('get', '/xml_datastreams/descMetadata', { xmlDatastream });

      await renderApp(<XmlDatastreamsEditRoute />, {
        path: '/xml-datastreams/:xmlDatastreamStringKey/edit',
        url: '/xml-datastreams/descMetadata/edit',
      });

      expect(await screen.findByDisplayValue('descMetadata')).toBeInTheDocument();
      expect(screen.getByDisplayValue('Descriptive Metadata')).toBeInTheDocument();
      expect(screen.getByRole('textbox', { name: 'XML Translation' })).toHaveValue('{"render_if": {"present": ["restriction_on_access"]}}');
    });

    it('should disable the String Key field in edit mode', async () => {
      const xmlDatastream = buildXmlDatastream({ stringKey: 'descMetadata' });

      mockApiV2('get', '/xml_datastreams/descMetadata', { xmlDatastream });

      await renderApp(<XmlDatastreamsEditRoute />, {
        path: '/xml-datastreams/:xmlDatastreamStringKey/edit',
        url: '/xml-datastreams/descMetadata/edit',
      });

      const stringKeyInput = await screen.findByDisplayValue('descMetadata');
      expect(stringKeyInput).toBeDisabled();
    });
  });

  describe('updating an xml datastream', () => {
    it('should show success alert after saving changes', async () => {
      const xmlDatastream = buildXmlDatastream({
        stringKey: 'descMetadata',
        displayLabel: 'Descriptive Metadata',
      });

      mockApiV2('get', '/xml_datastreams/descMetadata', { xmlDatastream });
      mockApiV2('patch', '/xml_datastreams/descMetadata', {
        xmlDatastream: { ...xmlDatastream, displayLabel: 'Descriptive Metadata Updated' },
      });

      await renderApp(<XmlDatastreamsEditRoute />, {
        path: '/xml-datastreams/:xmlDatastreamStringKey/edit',
        url: '/xml-datastreams/descMetadata/edit',
      });

      const displayLabelInput = await screen.findByDisplayValue('Descriptive Metadata');

      await userEvent.clear(displayLabelInput);
      await userEvent.type(displayLabelInput, 'Descriptive Metadata Updated');

      await userEvent.click(screen.getByRole('button', { name: 'Save' }));

      expect(
        await screen.findByText(/xml datastream updated successfully/i),
      ).toBeInTheDocument();
    });

    it('should show error alert when update fails', async () => {
      const xmlDatastream = buildXmlDatastream({
        stringKey: 'descMetadata',
        displayLabel: 'Descriptive Metadata',
      });

      mockApiV2('get', '/xml_datastreams/descMetadata', { xmlDatastream });
      mockApiV2('patch', '/xml_datastreams/descMetadata', { error: 'Update failed' }, 422);

      await renderApp(<XmlDatastreamsEditRoute />, {
        path: '/xml-datastreams/:xmlDatastreamStringKey/edit',
        url: '/xml-datastreams/descMetadata/edit',
      });

      await screen.findByDisplayValue('Descriptive Metadata');

      await userEvent.click(screen.getByRole('button', { name: 'Save' }));

      expect(
        await screen.findByText(/error updating xml datastream/i),
      ).toBeInTheDocument();
    });
  });
});
