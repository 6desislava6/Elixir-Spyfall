[{kernel,
 [{distributed, [{'spyfall_server', 5000, ['server@desi-beli', {'backup@desi-beli', 'backup2@desi-beli'}]}]},
 {sync_nodes_mandatory, ['server@desi-beli', 'backup2@desi-beli']},
 {sync_nodes_timeout, 30000}
 ]}]