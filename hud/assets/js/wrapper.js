(() => {

	let ChunkWrapper = {};
	ChunkWrapper.MessageSize = 1024;
	ChunkWrapper.messageId = 0;

	window.SendMessage = function (namespace, name, type, msg) {

		ChunkWrapper.messageId = (ChunkWrapper.messageId < 65535) ? ChunkWrapper.messageId + 1 : 0;
		const str = JSON.stringify(msg);

		for (let i = 0; i < str.length; i++) {

			let count = 0;
			let chunk = '';

			while (count < ChunkWrapper.MessageSize && i < str.length) {

				chunk += str[i];

				count++;
				i++;
			}

			i--;

			const data = {
				__namespace: namespace,
				__name: name,
				__type: type,
				id: ChunkWrapper.messageId,
				chunk: chunk
			}

			if (i == str.length - 1)
				data.end = true;

			$.post('http://corev/__chunk', JSON.stringify(data));

		}

	}

})();