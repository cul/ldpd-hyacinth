import { describe, it, expect, vi, beforeAll, afterAll, type Mock } from 'vitest';
import {
  buildXmlDatastream,
  mockApiV2,
  renderApp,
  screen,
  within,
} from '@/testing/test-utils';
import { XmlDatastreamsList } from '@/features/xml-datastreams/components/xml-datastreams-list';
import FeatureLayout from '@/components/layouts/feature-layout';

beforeAll(() => {
  vi.spyOn(console, 'error').mockImplementation(() => { });
});

afterAll(() => {
  (console.error as Mock).mockRestore();
});

describe('XML Datastreams Index Route', () => {
  it('should display xml datastreams list in a table with correct data from API', async () => {
    const ds1 = buildXmlDatastream({
      stringKey: 'descMetadata',
      displayLabel: 'Descriptive Metadata',
    });
    const ds2 = buildXmlDatastream({
      stringKey: 'testMetadata',
      displayLabel: 'Test Metadata',
    });

    mockApiV2('get', '/xml_datastreams', { xmlDatastreams: [ds1, ds2] });

    await renderApp(<XmlDatastreamsList />, { url: '/xml-datastreams' });

    expect(await screen.findByText('Descriptive Metadata')).toBeInTheDocument();
    expect(screen.getByText('Test Metadata')).toBeInTheDocument();
    expect(screen.getByText('descMetadata')).toBeInTheDocument();
    expect(screen.getByText('testMetadata')).toBeInTheDocument();
  });

  it('should display correct column headers', async () => {
    const ds = buildXmlDatastream({ stringKey: 'test' });

    mockApiV2('get', '/xml_datastreams', { xmlDatastreams: [ds] });

    await renderApp(<XmlDatastreamsList />, { url: '/xml-datastreams' });

    await screen.findByRole('table');

    const expectedColumns = ['Display Label', 'String Key'];

    for (const columnName of expectedColumns) {
      expect(screen.getByRole('columnheader', { name: columnName })).toBeInTheDocument();
    }
  });

  it('should render display label as a link to the edit page', async () => {
    const ds = buildXmlDatastream({
      stringKey: 'descMetadata',
      displayLabel: 'Descriptive Metadata',
    });

    mockApiV2('get', '/xml_datastreams', { xmlDatastreams: [ds] });

    await renderApp(<XmlDatastreamsList />, { url: '/xml-datastreams' });

    const link = await screen.findByRole('link', { name: 'Descriptive Metadata' });

    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute('href', '/xml-datastreams/descMetadata/edit');
  });

  it('should display data sorted in ascending order by Display Label', async () => {
    const ds1 = buildXmlDatastream({ displayLabel: 'Alpha Datastream', stringKey: 'alpha' });
    const ds2 = buildXmlDatastream({ displayLabel: 'Beta Datastream', stringKey: 'beta' });
    const ds3 = buildXmlDatastream({ displayLabel: 'Gamma Datastream', stringKey: 'gamma' });

    mockApiV2('get', '/xml_datastreams', { xmlDatastreams: [ds1, ds2, ds3] });

    await renderApp(<XmlDatastreamsList />, { url: '/xml-datastreams' });

    await screen.findByRole('table');

    const rows = screen.getAllByRole('row');
    const names = rows.slice(1).map((row) => within(row).getAllByRole('cell')[0].textContent);

    expect(names).toEqual(['Alpha Datastream', 'Beta Datastream', 'Gamma Datastream']);
  });

  it('should display the Create New XML Datastream button', async () => {
    const ds = buildXmlDatastream({ stringKey: 'testMetadata' });

    mockApiV2('get', '/xml_datastreams', { xmlDatastreams: [ds] });

    await renderApp(<FeatureLayout featureName="XML Datastream" />, { url: '/xml-datastreams' });

    const createButton = await screen.findByRole('button', { name: /create new xml datastream/i });

    expect(createButton).toBeInTheDocument();
  });
});
