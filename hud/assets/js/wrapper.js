(() => {
	let ChunkWrapper = {};

	ChunkWrapper.MessageSize = 1024;
	ChunkWrapper.messageId = 0;

	window.SendMessage = function (namespace, name, messageType, msg) {
		msg.__type = messageType;

		ChunkWrapper.messageId = (ChunkWrapper.messageId < 65535) ? ChunkWrapper.messageId + 1 : 0;

		const _data = JSON.parse(JSON.stringify(msg));

		if (_data.items != null || typeof _data.items != 'undefined') {
			delete _data.items;
		}

		const str = JSON.stringify(_data);

		for (let i = 0; i < str.length; i++) {

			let count = 0;
			let chunk = '';

			while (count < ChunkWrapper.MessageSize && i < str.length) {

				chunk += str[i];

				count++;
				i++;
			}

			i--;

			let data = {
				__namespace: namespace,
				__name: name,
				__type: messageType,
				id: ChunkWrapper.messageId,
				chunk: chunk
			}

			if (i == str.length - 1)
				data.end = true;

			$.post('http://corev/__chunk', JSON.stringify(data));
		}
	}
})();