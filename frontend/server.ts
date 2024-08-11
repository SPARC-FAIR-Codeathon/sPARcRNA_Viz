/* eslint-disable no-undef */
import { faker } from '@faker-js/faker'
import Hapi from '@hapi/hapi'

const init = async () => {
  const server = Hapi.server({
    host: 'localhost',
    port: 3001,
    routes: {
      cors: {
        origin: ['*']
      }
    }
  })

  server.route({
    path: '/',
    handler: (_request, _h) => {
      return 'Hello World!'
    },
    method: 'GET'
  })

  server.route({
    path: '/hello/{name}',
    handler: (request, _h) => {
      return `Hello ${encodeURIComponent(request.params.name)}!`
    },
    method: 'GET'
  })

  server.route({
    path: '/getData/{numPoints}',
    handler: (_request, _h) => {
      // Create a random array of data for a t-sne plot

      const numberOfPoints = parseInt(_request.params.numPoints, 10) || 100

      // Generate 10 random music genres
      const genres = Array.from({ length: 30 }, () => faker.music.genre())

      // Reduce the genres to a unique set of genres
      const uniqueGenres = genres.reduce<string[]>((acc, genre) => {
        if (!acc.includes(genre)) {
          acc.push(genre)
        }
        return acc
      }, [])

      // Limit the number of genres to 10
      const limitedGenres = uniqueGenres.slice(0, 10)

      // Generate 1000 random data points
      let id = 0
      const data = Array.from({ length: numberOfPoints }, () => {
        return {
          id: id++,
          title: faker.music.songName(),
          genre: faker.helpers.arrayElement(limitedGenres).replace(' ', '_'),
          x: Math.floor(Math.random() * 100),
          y: Math.floor(Math.random() * 100)
        }
      })

      return data
    },
    method: 'GET'
  })

  await server.start()

  console.log('Server running on %s', server.info.uri)
}

process.on('unhandledRejection', (err) => {
  console.log(err)
  process.exit(1)
})

init()
